-- vim: tw=78:

-- ===========================================================================
-- nx-console.nvim - Nx Console plugin for Neovim
--
-- Apache 2.0 License. See LICENSE file for details.
-- ===========================================================================

---@tag nx-console.nvim
---@tag nx-console
---@toc_entry Introduction
---@toc

---@text
--- # Introduction ~
---
--- nx-console.nvim is a Neovim plugin that brings Nx Console functionality
--- to Neovim. It provides integration with the nxls language server to
--- interact with Nx workspaces directly from your editor - same as the
--- official VS Code plugin.
---
--- Requirements:
---   - Neovim 0.11 or later
---   - Node.js 20 or later (for running nxls)
---
--- Features:
---   - Integrated language server (nxls) for Nx workspace intelligence
---   - Interactive pickers for projects, targets, and generators (currently
---     supporting Telescope, fzf-lua, Snacks)
---   - Neo-tree integration for visual workspace navigation
---   - Automatic nxls binary management (download & updates)
---   - LSP features for nx.json and project.json files
---   - Run Nx targets directly from Neovim
---
--- # Quick Start ~
---                                                    *nx-console-quickstart*
---
--- After installation, nx-console.nvim works with minimal configuration.
---
--- Basic setup: >lua
---   require('nx-console').setup({})
---
---   -- Neo-tree.nvim integration
---   require('neo-tree').setup({
---     sources = { "nx-console", "filesystem", "buffers", "git_status" },
---     ["nx-console"] = {
---       auto_refresh_on_workspace_change = true,
---     },
---   })
--- <
---
--- Also see |nx-console-neotree| for Neo-tree.nvim integration.
---
--- ## Basic Usage ~
---
--- Using Telescope: >vim
---   :Telescope nx-console projects
---   :Telescope nx-console targets
---   :Telescope nx-console targets_current
---   :Telescope nx-console generators
--- <
---
--- Using Lua API (works with any picker): >lua
---   -- List all projects
---   require('nx-console').pickers.projects()
---
---   -- List targets for a specific project
---   require('nx-console').pickers.targets({ project = "my-app" })
---
---   -- List targets for the current file's project
---   require('nx-console').pickers.targets_current()
---
---   -- List available generators
---   require('nx-console').pickers.generators()
---
---   -- Explicitly choose a picker
---   require('nx-console').pickers.projects({ picker = "fzf" })
---   require('nx-console').pickers.projects({ picker = "snacks" })
---   require('nx-console').pickers.projects({ picker = "telescope" })
--- <
---
--- Then navigate to the nx-console source in Neo-tree.
---
--- ## Recommended Keymaps ~
---                                                       *nx-console-keymaps*
--- >lua
---   -- Nx project pickers
---   vim.keymap.set('n', '<leader>np', function()
---     require('nx-console').pickers.projects()
---   end, { desc = 'Nx Projects' })
---
---   vim.keymap.set('n', '<leader>nt', function()
---     require('nx-console').pickers.targets()
---   end, { desc = 'Nx Targets' })
---
---   vim.keymap.set('n', '<leader>nT', function()
---     require('nx-console').pickers.targets_current()
---   end, { desc = 'Nx Targets (current file)' })
---
---   vim.keymap.set('n', '<leader>ng', function()
---     require('nx-console').pickers.generators()
---   end, { desc = 'Nx Generators' })
--- <

local config = require("nx-console.config")
local log = require("nx-console.log")
local nxls = require("nx-console.nxls")

local M = {}

-- Expose pickers
M.pickers = require("nx-console.pickers")

--- Setup function for nx-console.nvim.
---
--- Initializes the plugin with user configuration.
---
---@param opts? nx_console.Config Optional configuration table. See |nx_console.Config|.
---
---@usage >lua
---   -- Use defaults
---   require('nx-console').setup({})
--- <
M.setup = function(opts)
  if vim.fn.has("nvim-0.11") == 0 then
    log.error("nx-console.nvim requires Neovim 0.11 and newer")
    return
  end

  config.setup(opts)

  -- Auto-load Telescope extension if Telescope is available
  if pcall(require, "telescope") then
    pcall(function()
      ---@diagnostic disable-next-line:undefined-field
      require("telescope").load_extension("nx_console")
    end)
  end

  -- Load snacks picker source if available
  if Snacks and pcall(require, "snacks.picker") then
    Snacks.picker.sources.nx_console = require("nx-console.snacks").source
  end

  -- Start client immediately if lazy_start is enabled and we're in an Nx workspace
  if config.options.lazy_start and require("nx-console.nxls.util").is_nx_workspace() then
    vim.schedule(function()
      nxls.ensure_client_started()
    end)
  end
end

return M
