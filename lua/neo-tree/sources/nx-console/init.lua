-- vim: tw=78:

---@toc_entry Neo-tree Integration
---@tag nx-console-neotree
---@text
--- # Neo-tree Integration ~
---
--- nx-console.nvim provides a Neo-tree source for browsing your Nx workspace
--- visually. The tree shows projects organized by folder structure, with
--- targets listed under each project.
---
--- Setup: >lua
---   require('neo-tree').setup({
---     sources = {
---       "nx-console",
---       "filesystem",
---       "buffers",
---       "git_status",
---     },
---     nx_console = {
---       -- Auto-refresh when workspace changes (default: true)
---       auto_refresh_on_workspace_change = true,
---
---       -- Override mappings (these are the defaults)
---       window = {
---         mappings = {
---           ["<CR>"] = "open_or_run",
---           ["o"] = "open_or_run",
---           ["R"] = "refresh",
---         }
---       }
---     },
---   })
--- <
---
--- ## Caching ~
---
--- The tree is cached to avoid unnecessary LSP requests. The cache is
--- automatically invalidated when:
---
---   - The Nx workspace is refreshed (via LSP notification)
---   - Force refresh is requested

local async = require("plenary.async")

local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local events = require("neo-tree.events")
local utils = require("neo-tree.utils")

local types = require("neo-tree.sources.nx-console.types")
local prepare_nx_tree = require("neo-tree.sources.nx-console.lib.prepare-nx-tree")

local util = require("nx-console.util")
local nxls = require("nx-console.nxls")
local notification_types = require("nx-console.nxls.types").notification_types

local get_project_folder_tree = require("nx-console.workspace.get-project-folder-tree")
local get_project_by_path = require("nx-console.workspace.get-project-by-path")

local M = {
  name = "nx-console",
  display_name = "Nx",
}

--- Cache for workspace tree
---@private
---@type table<nx_console.NeoTree.TreeNode> | nil
local cached_nodes = nil

-- Start as dirty to load on first navigate
local workspace_dirty = true

---@private
M.default_config = {
  use_default_mappings = false,

  -- Auto-refresh the tree when Nx workspace changes (via LSP notification)
  -- Set to false to only refresh when invoking the refresh command
  auto_refresh_on_workspace_change = true,

  window = {
    mappings = {
      ["<CR>"] = "open_or_run",
      ["o"] = "open_or_run",
      ["R"] = "refresh",

      -- Add essential common mappings
      ["<esc>"] = "cancel",
      ["q"] = "close_window",
      ["?"] = "show_help",
      ["<"] = "prev_source",
      [">"] = "next_source",
    },
  },
}

--- Mark workspace as dirty (needs refresh)
---@private
M.mark_dirty = function()
  workspace_dirty = true
end

---@private
---@param message string
---@param state any
local set_status_node = function(message, state)
  ---@type nx_console.NeoTree.TreeNode
  local node = {
    id = "nx-console-status",
    name = message,
    type = "directory",
    extra = { type = types.node_types.NxStatus },
    children = {},
    path = "",
    is_reveal_target = false,
    contains_reveal_target = false,
  }

  renderer.show_nodes({ node }, state)
end

---@async
---@private
---@return table<nx_console.NeoTree.TreeNode> | nil
---@return string | nil
local refresh_async = function()
  local project_tree, err = get_project_folder_tree()
  if err then
    return nil, err
  end

  if project_tree == nil then
    return nil, "No project tree returned"
  end

  ---@type table<nx_console.NeoTree.TreeNode>
  local nodes = {}
  for _, node in ipairs(project_tree.roots) do
    prepare_nx_tree(nodes, node, project_tree.tree_map)
  end

  return nodes, nil
end

--- Preserve and restore expanded state when rendering nodes
---@private
---@param state neotree.StateWithTree
---@param nodes table<nx_console.NeoTree.TreeNode> | nil
local function render_with_expanded_state(state, nodes)
  -- Preserve expanded state before rendering
  local expanded_nodes = {}
  if state.tree then
    expanded_nodes = renderer.get_expanded_nodes(state.tree)
  end

  renderer.show_nodes(nodes, state)

  -- Restore expanded state after rendering
  for _, node_id in ipairs(expanded_nodes) do
    local node = state.tree:get_node(node_id)
    if node and not node:is_expanded() then
      node:expand()
    end
  end

  -- Redraw to show the expanded state
  if #expanded_nodes > 0 then
    renderer.redraw(state)
  end
end

--- Reveal a project in the tree if valid
---@private
---@param state neotree.StateWithTree
---@param project_to_reveal nx_console.ProjectConfiguration | nil
---@param err string | nil
local function reveal_project(state, project_to_reveal, err)
  if not err and project_to_reveal ~= nil and project_to_reveal.name then
    renderer.position.set(state, project_to_reveal.name)
  end
end

--- Render nodes from cache with optional reveal
---@private
---@param state neotree.StateWithTree
---@param path_to_reveal string | nil
local function render_from_cache(state, path_to_reveal)
  if path_to_reveal then
    async.run(function()
      local project_to_reveal, err = get_project_by_path({ projectPath = path_to_reveal })

      vim.schedule(function()
        render_with_expanded_state(state, cached_nodes)
        reveal_project(state, project_to_reveal, err)
      end)
    end, util.noop)

    return
  end

  -- No reveal needed, just render
  render_with_expanded_state(state, cached_nodes)
end

--- Perform async refresh and update UI
---@private
---@param state neotree.StateWithTree
---@param path_to_reveal string | nil
local function perform_async_refresh(state, path_to_reveal)
  async.run(function()
    local nodes, err = refresh_async()

    -- Get project for reveal in async context if needed
    local project_to_reveal = nil
    local proj_err = nil
    if path_to_reveal then
      project_to_reveal, proj_err = get_project_by_path({ projectPath = path_to_reveal })
    end

    -- Schedule UI update on main thread
    vim.schedule(function()
      if err then
        set_status_node("Error: " .. err, state)
        return
      end

      if nodes == nil or #nodes == 0 then
        set_status_node("Nothing to show", state)
        return
      end

      -- Cache the nodes and mark workspace as clean
      cached_nodes = nodes
      workspace_dirty = false

      render_with_expanded_state(state, nodes)
      reveal_project(state, project_to_reveal, proj_err)
    end)
  end, function(async_err)
    if async_err then
      vim.schedule(function()
        set_status_node("Error: " .. tostring(async_err), state)
      end)
    end
  end)
end

---Navigate to the given path.
---@private
---@param state neotree.StateWithTree
---@param path string Path to navigate to. If empty, will navigate to the cwd.
---@param path_to_reveal string | nil Path to reveal in the tree
---@param force_refresh boolean | nil Force refresh even if cache is valid
M.navigate = function(state, path, path_to_reveal, force_refresh)
  if path == nil then
    path = vim.fn.getcwd()
  end
  state.path = path

  -- Ensure nxls client is started on-demand
  nxls.ensure_client_started(function(nxls_instance)
    -- After ensuring client is started (or confirmed not in Nx workspace)
    if not nxls_instance:is_running() then
      set_status_node("Nxls is not running", state)
      return
    end

    -- Continue with navigation
    M._navigate_internal(state, path, path_to_reveal, force_refresh)
  end)
end

---@private
---@param state neotree.StateWithTree
---@param path string
---@param path_to_reveal string?
---@param force_refresh boolean?
M._navigate_internal = function(state, path, path_to_reveal, force_refresh)
  -- Use cached nodes if available and workspace is not dirty
  if cached_nodes and not workspace_dirty and not force_refresh then
    render_from_cache(state, path_to_reveal)
    return
  end

  -- Show loading state first
  set_status_node("Loading...", state)

  -- Perform async refresh and update UI
  perform_async_refresh(state, path_to_reveal)
end

---@private
M.setup = function()
  nxls.on_notification(notification_types.NxWorkspaceRefreshNotification, function()
    M.mark_dirty()

    -- Check if auto-refresh is enabled
    vim.schedule(function()
      local state = manager.get_state("nx-console")

      -- Only refresh if state exists, tree is visible, and window is open
      if state and state.tree and state.winid and vim.api.nvim_win_is_valid(state.winid) then
        local source_config = state.config or M.default_config
        local auto_refresh = source_config.auto_refresh_on_workspace_change

        if auto_refresh ~= false then
          ---@diagnostic disable-next-line: param-type-mismatch
          M.navigate(state, state.path)
        end
      end
    end)
  end)
end

return M
