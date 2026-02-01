local log = require("nx-console.log")

---@param opts TermCreateArgs | nil
---@return nx_console.Config.CommandRunner
local function create_toggleterm_runner(opts)
  return function(cmd)
    local has_toggleterm, toggleterm = pcall(require, "toggleterm.terminal")
    if not has_toggleterm then
      log.error("toggleterm.nvim is not installed")
      return
    end

    local Terminal = toggleterm.Terminal

    ---@type table
    local defaults = {
      cmd = cmd,
      direction = "horizontal",
      close_on_exit = false,
    }

    local config = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    local term = Terminal:new(config)
    term:toggle()
  end
end

return create_toggleterm_runner
