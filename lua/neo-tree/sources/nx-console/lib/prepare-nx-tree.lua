local util = require("nx-console.util")
local types = require("neo-tree.sources.nx-console.types")
local nodes = require("neo-tree.sources.nx-console.lib.nodes")

---@param tree_node nx_console.NeoTree.TreeNode
---@param nx_node nx_console.TreeNode
---@param nx_tree_map nx_console.TreeMap
local process_children = function(tree_node, nx_node, nx_tree_map)
  for _, child in ipairs(nx_node.children) do
    local child_node = nx_tree_map[child]
    if child_node then
      PrepareNxTree(tree_node.children, child_node, nx_tree_map)
    end
  end
end

---@param targets table<string, nx_console.TargetConfiguration>
---@param target_groups table<string, string[]>
---@return table<string, string[]>
local group_targets_by_groups = function(targets, target_groups)
  return util.group_by(vim.tbl_keys(targets), function(target_name, _)
    for group_name, group_targets in pairs(target_groups) do
      if vim.tbl_contains(group_targets, target_name) then
        return group_name
      end
    end

    return types.Ungrouped
  end)
end

---@param tree_node table
---@param nx_node nx_console.TreeNode
---@param targets table<string, nx_console.TargetConfiguration>
---@param target_groups table<string, string[]>
local function prepare_target_nodes(tree_node, nx_node, targets, target_groups)
  local targets_by_groups = group_targets_by_groups(targets, target_groups)

  for group_name, group_targets in pairs(targets_by_groups) do
    local group_node = nodes.create_group_node(nx_node, group_name)

    for _, target_name in ipairs(group_targets) do
      local target = targets[target_name]
      local target_node = nodes.create_target_node(nx_node, group_name, target_name)

      -- Prepare target configurations, if any
      if target.configurations then
        for config_name, _ in pairs(target.configurations) do
          local config_node = nodes.create_target_node(nx_node, group_name, target_name, config_name)
          table.insert(target_node.children, config_node)
        end
      end

      table.insert(group_node.children, target_node)
    end

    if group_name == types.Ungrouped then
      -- If the group is ungrouped, add its children directly to the tree node
      for _, child in ipairs(group_node.children) do
        table.insert(tree_node.children, child)
      end
    else
      -- Otherwise add the target group node
      table.insert(tree_node.children, group_node)
    end
  end
end

---@param tree_nodes_root table<nx_console.NeoTree.TreeNode>
---@param nx_node nx_console.TreeNode
---@param nx_tree_map nx_console.TreeMap
function PrepareNxTree(tree_nodes_root, nx_node, nx_tree_map)
  -- Create the neotree tree node representing this nx_node
  local tree_node = nodes.create_project_or_directory_node(nx_node)

  -- Process its children
  process_children(tree_node, nx_node, nx_tree_map)

  -- Add the processed node to the root
  table.insert(tree_nodes_root, tree_node)

  if nx_node.projectConfiguration == nil then
    return
  end

  -- If this node is a project, continue proccessing its targets
  local targets = nx_node.projectConfiguration.data.targets or {}
  local target_groups = (nx_node.projectConfiguration.data.metadata or {}).targetGroups or {}

  prepare_target_nodes(tree_node, nx_node, targets, target_groups)
end

return PrepareNxTree
