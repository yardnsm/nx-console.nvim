local log = require("nx-console.log")

local M = {}

local subcommands = {
  start = require("nx-console.commands.start"),
  stop = require("nx-console.commands.stop"),
  refresh = require("nx-console.commands.refresh"),
  download = require("nx-console.commands.download"),
}

---@param args string[]
function M.execute(args)
  local cmd = args[1]
  if not subcommands[cmd] then
    log.error("Unknown subcommand: " .. cmd)
    return
  end

  subcommands[cmd].fn()
end

---@param arg_lead string
---@param cmd_line string
---@param cursor_pos number
---@return string[]
function M.complete(arg_lead, cmd_line, cursor_pos)
  local parts = vim.split(cmd_line, "%s+")

  -- Complete subcommand
  if #parts <= 2 then
    local matches = {}
    for name, _ in pairs(subcommands) do
      if name:match("^" .. vim.pesc(arg_lead)) then
        table.insert(matches, name)
      end
    end
    table.sort(matches)
    return matches
  end

  return {}
end

return M
