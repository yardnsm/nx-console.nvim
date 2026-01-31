local config = require("nx-console.config")
local log = require("nx-console.log")
local client = require("nx-console.nxls.client")
local util = require("nx-console.nxls.util")

local M = {}

--- Start nxls client on-demand if not already running
---@param callback? fun(nxls: nx_console.NxlsClient) Optional callback when client is ready
function M.ensure_client_started(callback)
  local nxls = client.get_nxls()

  -- Check if already running
  if nxls:is_running() then
    if callback then
      callback(nxls)
    end
    return
  end

  -- Don't auto-start if the user explicitly stopped it
  if nxls:was_explicitly_stopped() then
    if callback then
      callback(nxls)
    end
    return
  end

  -- Check if we're in an Nx workspace
  if not util.is_nx_workspace() then
    log.warn("Not in an Nx workspace (no nx.json found)")
    if callback then
      callback(nxls)
    end
    return
  end

  -- Ensure binary is downloaded before starting
  if not config.options.nxls.nxls_path and config.options.nxls.download.auto then
    require("nx-console.nxls.download").ensure_downloaded(function(err)
      if err then
        log.error("Failed to download nxls: " .. err)
        if callback then
          callback(nxls)
        end
        return
      end

      nxls:start_client()
      if callback then
        callback(nxls)
      end
    end)
    return
  end

  -- Start client immediately if not downloading
  nxls:start_client()
  if callback then
    callback(nxls)
  end
end

---@param buf integer
function M.ensure_client_attached(buf)
  M.ensure_client_started(function(nxls)
    if nxls:is_running() then
      nxls:attach_buffer(buf)
    end
  end)
end

---@param notification_type nx_console.NotificationType
---@param callback fun(result: any)
---@return fun() unsubscribe function to remove the callback
function M.on_notification(notification_type, callback)
  return client.get_nxls():on_notification(notification_type, callback)
end

M.get_nxls = client.get_nxls

return M
