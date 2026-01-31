---@class nx_console.PubSub
---
---@field _listeners table<string, fun(data: any)[]>
local PubSub = {}
PubSub.__index = PubSub

function PubSub.new()
  ---@type nx_console.PubSub
  local self = {
    _listeners = {},
  }

  setmetatable(self, PubSub)
  return self
end

--- Subscribe to an event
---@param event string
---@param callback fun(data: any)
---@return fun() unsubscribe function
function PubSub:subscribe(event, callback)
  if self._listeners[event] == nil then
    self._listeners[event] = {}
  end

  table.insert(self._listeners[event], callback)

  return function()
    local listeners = self._listeners[event]
    if not listeners then
      return
    end

    for i, cb in ipairs(listeners) do
      if cb == callback then
        table.remove(listeners, i)
        return
      end
    end
  end
end

--- Publish an event to all subscribers
---@param event string
---@param data any
function PubSub:publish(event, data)
  local listeners = self._listeners[event]
  if not listeners then
    return
  end

  for _, callback in ipairs(listeners) do
    callback(data)
  end
end

return PubSub
