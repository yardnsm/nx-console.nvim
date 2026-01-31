---@module 'snacks'

local log = require("nx-console.log")

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

    local title = "[Nx Console] " .. cmd

    ---@type snacks.terminal.Opts
    local defaults = {
      auto_close = false,
      win = {
        wo = {
          winbar = title,
        },
        title = title,
        position = "right",
        height = 0.4,
      },
    }

    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    ---@diagnostic disable-next-line:undefined-field
    snacks.terminal(cmd, opts)
  end
end

return create_snacks_runner
