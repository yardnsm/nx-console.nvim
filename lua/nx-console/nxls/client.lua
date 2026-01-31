local async = require("plenary.async")

local log = require("nx-console.log")
local config = require("nx-console.config")

local cmd = require("nx-console.nxls.cmd")
local types = require("nx-console.nxls.types")
local util = require("nx-console.nxls.util")

local ProgressEmitter = require("nx-console.nxls.progress")
local PubSub = require("nx-console.pubsub")

local M = {}

---@type nx_console.NxlsClient | nil
local _nxls_client = nil

---@class nx_console.NxlsClient
---
---@field _client vim.lsp.Client | nil
---@field _workspace_path string | nil
---@field _pubsub nx_console.PubSub
---@field _explicitly_stopped boolean Track if user explicitly stopped the server
local NxlsClient = {}
NxlsClient.__index = NxlsClient

function NxlsClient.new()
  ---@type nx_console.NxlsClient
  local self = {
    _client = nil,
    _pubsub = PubSub.new(),
    _workspace_path = nil,
    _explicitly_stopped = false,
  }

  setmetatable(self, NxlsClient)

  return self
end

---@param workspace_path nx_console.WorkspacePath | nil
---@param opts? { bufnr?: number } Optional settings for starting the client
function NxlsClient:start_client(workspace_path, opts)
  opts = opts or {}
  workspace_path = workspace_path or vim.fn.getcwd()

  if self._client and not self._client:is_stopped() then
    log.info("Nxls client is already running")
    return
  end

  local root_dir = util.get_nx_workspace_root(workspace_path)
  if not root_dir then
    error("Could not find nx.json root directory")
  end

  -- For on-demand startup, we use vim.lsp.start() directly
  local client_id = vim.lsp.start({
    name = "nxls",
    cmd = cmd.get_nxls_cmd(),
    root_dir = root_dir,

    handlers = {
      [types.notification_types.NxWorkspaceRefreshStartedNotification] = function()
        self._pubsub:publish(types.notification_types.NxWorkspaceRefreshStartedNotification)
      end,
      [types.notification_types.NxWorkspaceRefreshNotification] = function()
        self._pubsub:publish(types.notification_types.NxWorkspaceRefreshNotification)
      end,
    },

    init_options = {
      workspacePath = workspace_path,
    },

    on_init = function(client, initialization_result)
      self:_on_init(client, initialization_result)
    end,

    on_attach = function(client, bufnr)
      self:_on_attach(client, bufnr)
    end,

    on_exit = function(code, signal, client_id)
      self:_on_exit(code, signal, client_id)
    end,
  }, opts)

  if client_id == nil then
    log.error("Unable to start nxls" .. vim.inspect(client_id))
    return
  end

  self._workspace_path = workspace_path
  self._client = vim.lsp.get_client_by_id(client_id)
  self._explicitly_stopped = false
end

function NxlsClient:stop()
  if not self._client then
    return
  end

  self._explicitly_stopped = true
  vim.lsp.stop_client(self._client.id)
end

---@return vim.lsp.Client
function NxlsClient:get_client()
  if not self._client then
    error("NxlsClient is not initialized")
  end

  return self._client
end

---@param bufnr number
function NxlsClient:attach_buffer(bufnr)
  if not self._client then
    error("NxlsClient is not initialized")
    return
  end

  vim.lsp.buf_attach_client(bufnr, self._client.id)
end

function NxlsClient:is_running()
  if not self._client then
    return false
  end

  return not self._client:is_stopped()
end

--- Check if the user has explicitly stopped the server
---@return boolean
function NxlsClient:was_explicitly_stopped()
  return self._explicitly_stopped
end

--- Create a progress emitter for this client
---@param title? string Optional title for the progress
---@return nx_console.ProgressEmitter
function NxlsClient:create_progress_emitter(title)
  if not self._client then
    error("NxlsClient is not initialized")
  end

  return ProgressEmitter.new(self._client, title)
end

--- Handle LSP client initialization
---@param client vim.lsp.Client
---@param initialization_result table
function NxlsClient:_on_init(client, initialization_result)
  log.debug("Initialized nxls with id " .. client.id)
  client:notify(types.notification_types.NxWorkspaceRefreshNotification, {})
  config.options.nxls.on_init(client, initialization_result)
end

--- Handle LSP client attach
---@param client vim.lsp.Client
---@param bufnr number
function NxlsClient:_on_attach(client, bufnr)
  config.options.nxls.on_attach(client, bufnr)
end

--- Handle LSP client exit
---@param code number
---@param signal number
---@param client_id number
function NxlsClient:_on_exit(code, signal, client_id)
  -- Mark as explicitly stopped when server exits
  self._explicitly_stopped = true

  config.options.nxls.on_exit(code, signal, client_id)
end

function NxlsClient:set_workspace_path(workspace_path)
  if not self._client then
    error("NxlsClient is not initialized")
    return
  end

  self._workspace_path = workspace_path
  self._client:notify(types.notification_types.NxWorkspaceChangeNotification, workspace_path)
end

---@async
---@param method string
---@param params? table
function NxlsClient:request_async(method, params)
  if not self._client then
    error("NxlsClient is not initialized")
  end

  local async_req = async.wrap(self._client.request, 4)
  return async_req(self._client, method, params)
end

function NxlsClient:refresh_workspace()
  local progress = self:create_progress_emitter("Refreshing workspace")

  local refresh = function()
    if self:is_running() then
      progress:report("Stopping nx daemon", 10)
      self:request_async(types.request_types.NxStopDaemonRequest, {})
    end

    progress:report("Restarting language server", 30)

    -- Start without attaching to any buffer to avoid triggering unwanted side effects
    self:start_client(self._workspace_path, { bufnr = 0 })

    progress:report("Refreshing workspace", 60)
    self._client:notify(types.notification_types.NxWorkspaceRefreshNotification, {})

    ---@type fun()
    local dispose = nil
    dispose = self:on_notification(types.notification_types.NxWorkspaceRefreshNotification, function()
      progress:finish("Workspace refreshed", 100)
      dispose()
    end)
  end

  async.run(refresh, function() end)
end

--- Register a callback for a notification type
---@param notification_type nx_console.NotificationType
---@param callback fun(result: any)
---@return fun() unsubscribe function to remove the callback
function NxlsClient:on_notification(notification_type, callback)
  return self._pubsub:subscribe(notification_type, callback)
end

M.get_nxls = function()
  if not _nxls_client then
    _nxls_client = NxlsClient.new()
  end

  return _nxls_client
end

return M
