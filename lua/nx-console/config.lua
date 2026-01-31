-- vim: tw=78:

---@toc_entry Configuration
---@tag nx-console-configuration
---@tag nx_console.Config

local M = {}

---@private
---@type nx_console.Config
vim.g.nx_console_opts = vim.g.nx_console_opts

---@alias nx_console.Config.PickerOption nx_console.Picker.AdapterType
---@alias nx_console.Config.CommandRunner fun(cmd: string): nil

--- Configuration options for nx-console.nvim.
---
--- All fields are optional. Default values are shown below.
---
---@class nx_console.Config
---
---@text
--- Default configuration: ~
---
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
--minidoc_replace_start defaults = {
local defaults = {
  --minidoc_replace_end
  -- Whether to start the client lazily (when opening Neo-tree or pickers, for
  -- example). Set to false to start when setup() is called (only within Nx
  -- workspace).
  lazy_start = true,

  -- Picker to use for Nx pickers (nil = auto-detect)
  -- Options: "telescope", "fzf", "snacks", nil
  ---@type nx_console.Config.PickerOption
  picker = nil,

  nxls = {
    -- Path to nxls binary. If nil, will use downloaded binary
    ---@type string | nil
    nxls_path = nil,

    -- Node command to use to start nxls
    node_command = { "node" },

    -- Download settings
    download = {
      -- Enable automatic download of nxls
      auto = true,

      -- Override the auto-detected nxls revision (submodule SHA)
      ---@type string | nil
      nxls_revision = nil,
    },

    -- LSP callbacks
    ---@type vim.lsp.client.on_init_cb
    on_init = function() end,

    ---@type vim.lsp.client.on_attach_cb
    on_attach = function() end,

    ---@type vim.lsp.client.on_exit_cb
    on_exit = function() end,
  },

  -- The nx command used as a prefix
  nx_command = { "nx" },

  -- Command runner function.
  ---@type nx_console.Config.CommandRunner
  command_runner = require("nx-console.runners").snacks(),
}
--minidoc_afterlines_end

---@private
---@type nx_console.Config
M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.g.nx_console_opts or {})

---@private
---@param options? nx_console.Config
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})
end

return M
