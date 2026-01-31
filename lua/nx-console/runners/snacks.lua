---@module 'snacks'

local log = require("nx-console.log")

---@type snacks.terminal.Opts
local defaults = {
  auto_close = false,
  win = {
    wo = {
      winbar = "Nx Console",
    },
    title = "Nx Console",
    position = "right",
    height = 0.4,
  },
}

---@param opts snacks.terminal.Opts | nil
---@return nx_console.Config.CommandRunner
local function create_snacks_runner(opts)
  return function(cmd)
    local has_snacks, snacks = pcall(require, "snacks")
    if not has_snacks then
      log.error("Snacks.nvim is not installed")
      return
    end

    ---@diagnostic disable-next-line:undefined-field
    if not snacks.terminal then
      log.error("Snacks.nvim terminal is not available")
      return
    end

    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    ---@diagnostic disable-next-line:undefined-field
    snacks.terminal(cmd, opts)
  end
end

return create_snacks_runner
