local log = require("nx-console.log")

---@param opts Options | nil
---@return nx_console.Config.CommandRunner
local function create_yeet_runner(opts)
  return function(cmd)
    local has_yeet, yeet = pcall(require, "yeet")
    if not has_yeet then
      log.error("yeet.nvim is not installed")
      return
    end

    local config = vim.tbl_deep_extend("force", {}, opts or {})

    yeet.execute(cmd, config)
  end
end

return create_yeet_runner
