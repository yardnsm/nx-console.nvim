local M = {}

local title = "nx-console.nvim"

local function format_message(message)
  return "[nx-console] " .. message
end

local function should_log(level)
  local config = require("nx-console.config")
  return level >= config.options.log_level
end

M.trace = function(message)
  if not should_log(vim.log.levels.TRACE) then
    return
  end
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.TRACE, { title })
  end)
end

M.debug = function(message)
  if not should_log(vim.log.levels.DEBUG) then
    return
  end
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.DEBUG, { title })
  end)
end

M.info = function(message)
  if not should_log(vim.log.levels.INFO) then
    return
  end
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.INFO, { title })
  end)
end

M.warn = function(message)
  if not should_log(vim.log.levels.WARN) then
    return
  end
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.WARN, { title })
  end)
end

M.error = function(message)
  if not should_log(vim.log.levels.ERROR) then
    return
  end
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.ERROR, { title })
  end)
end

return M
