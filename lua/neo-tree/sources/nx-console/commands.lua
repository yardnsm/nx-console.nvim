-- vim: tw=78:

---@toc_entry Neo-tree Commands
---@tag nx-console-neotree-commands
---@text
--- # Neo-tree Commands ~
---
--- These commands are available when using the nx-console Neo-tree source.
--- They are mapped to keybindings in the Neo-tree window.
---
--- `open_or_run` - Smart action that behaves differently based on node type:
---   - On Nx target: Run the target
---   - On project/folder/target group: Toggle expansion
---   Mapped to `<CR>` and `o` by default.
---
--- `run_target` - Run the Nx target at the current node.
---
--- `refresh` - Force refresh the Nx workspace tree, bypassing the cache.
---   Mapped to `R` by default.
---
--- `show_debug_info` - Print debug information about the current Neo-tree
--- state. Useful for troubleshooting.
---

local cc = require("neo-tree.sources.common.commands")
local types = require("neo-tree.sources.nx-console.types")

local actions = require("nx-console.actions")

local M = {}

---@private
---@param node neotree.FileNode | NuiTree.Node
---@return {project: string, target: string, configuration?: string}|nil
local function get_target_from_node(node)
  ---@type nx_console.NeoTree.NodeExtra
  ---@diagnostic disable-next-line: assign-type-mismatch
  local extra = node.extra

  if extra and extra.type == types.node_types.NxTarget then
    return {
      project = extra.project_name,
      target = extra.target_name,
      configuration = extra.configuration,
    }
  end
  return nil
end

---@private
---@param node neotree.FileNode
---@param state neotree.StateWithTree
local function toggle_node(node, state)
  if node:is_expanded() then
    node:collapse()
  else
    node:expand()
  end
  state.tree:render()
end

---@private
---@param state neotree.StateWithTree
M.run_target = function(state)
  local node = state.tree and state.tree:get_node()

  local target_info = node and get_target_from_node(node)

  if target_info then
    actions.run_target(target_info)
  end
end

---@private
---@param state neotree.StateWithTree
M.refresh = function(state)
  local nx_console_source = require("neo-tree.sources.nx-console")
  nx_console_source.mark_dirty()
  nx_console_source.navigate(state, state.path, nil, true)
end

---@private
M.show_debug_info = function(state)
  print(vim.inspect(state))
end

---@private
M.open_or_run = function(state)
  local node = state.tree and state.tree:get_node()
  if not node then
    return
  end

  ---@type nx_console.NeoTree.NodeExtra
  ---@diagnostic disable-next-line: assign-type-mismatch
  local extra = node.extra
  local node_type = extra and extra.type

  -- If it's a target, run it
  if node_type == types.node_types.NxTarget then
    M.run_target(state)
    return
  end

  -- Otherwise toggle expansion for projects, target groups, and directories
  if
    node_type == types.node_types.NxTargetGroup
    or node_type == types.node_types.NxProject
    or node.type == "directory"
  then
    ---@diagnostic disable-next-line: param-type-mismatch
    toggle_node(node, state)
  end
end

-- Override the common "open" command to use our custom logic
M.open = M.open_or_run

cc._add_common_commands(M)
return M
