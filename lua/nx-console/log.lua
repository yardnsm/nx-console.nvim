local M = {}

local title = "nx-console.nvim"

local function format_message(message)
  return "[nx-console] " .. message
end

M.trace = function(message)
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.TRACE, { title })
  end)
end

M.debug = function(message)
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.DEBUG, { title })
  end)
end

M.info = function(message)
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.INFO, { title })
  end)
end

M.warn = function(message)
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.WARN, { title })
  end)
end

M.error = function(message)
  vim.schedule(function()
    vim.notify(format_message(message), vim.log.levels.ERROR, { title })
  end)
end

return M
