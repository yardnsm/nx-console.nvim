local last_used_token = -1

---@class nx_console.ProgressEmitter
---
---@field _token integer
---@field _client_id integer
---@field _title string?
local ProgressEmitter = {}
ProgressEmitter.__index = ProgressEmitter

---@param client? vim.lsp.Client
---@param title? string
function ProgressEmitter.new(client, title)
  ---@type nx_console.ProgressEmitter
  local self = {
    _token = last_used_token + 1,
    _client_id = client and client.id or -1,
    _title = title,
  }

  setmetatable(self, ProgressEmitter)

  last_used_token = self._token

  return self
end

---@param message string?
---@param percentage integer?
function ProgressEmitter:begin(message, percentage)
  self:emit("begin", self._title, message, percentage)
end

---@param message string?
---@param percentage integer?
function ProgressEmitter:report(message, percentage)
  self:emit("report", self._title, message, percentage)
end

---@param message string?
---@param percentage integer?
function ProgressEmitter:finish(message, percentage)
  self:emit("end", self._title, message, percentage)
end

---@param kind 'begin' | 'report' | 'end'
---@param message string | nil
---@param percentage number | nil
function ProgressEmitter:emit(kind, title, message, percentage)
  local client = vim.lsp.get_client_by_id(self._client_id)
  if not client then
    return
  end

  local progress_notification = {
    token = self._token,
    value = {
      kind = kind,
      title = title,
      message = message,
      percentage = percentage,
    },
  }

  vim.lsp.handlers["$/progress"](nil, progress_notification, {
    method = "$/progress",
    client_id = client.id,
  })
end

return ProgressEmitter
