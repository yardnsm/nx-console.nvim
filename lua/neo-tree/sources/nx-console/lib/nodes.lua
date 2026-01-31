local types = require("neo-tree.sources.nx-console.types")

local M = {}

---@param dir_or_project_name string
---@param group_name string?
---@param target_name string?
---@param config_node string?
---@return string
local create_node_id = function(dir_or_project_name, group_name, target_name, config_node)
  return table.concat({
    dir_or_project_name,
    group_name,
    target_name,
    config_node,
  }, "/")
end

---@param nx_node nx_console.TreeNode
---@return nx_console.NeoTree.TreeNode
M.create_project_or_directory_node = function(nx_node)
  ---@type nx_console.NeoTree.TreeNode
  return {
    id = create_node_id(nx_node.projectName or nx_node.dir),
    name = nx_node.projectName or vim.fn.fnamemodify(nx_node.dir, ":t"),
    type = "directory",

    ---@type nx_console.NeoTree.NodeExtra
    extra = {
      type = nx_node.projectConfiguration ~= nil and types.node_types.NxProject or types.node_types.NxDirectory,
      project_configuration = nx_node.projectConfiguration,
      project_name = nx_node.projectName,
    },

    children = {},

    path = nx_node.dir,
    is_reveal_target = true,
    contains_reveal_target = true,
  }
end

---@param nx_node nx_console.TreeNode
---@param group_name string
---@return nx_console.NeoTree.TreeNode
M.create_group_node = function(nx_node, group_name)
  ---@type nx_console.NeoTree.TreeNode
  return {
    id = create_node_id(nx_node.projectName, group_name),
    name = group_name,
    type = "directory",

    ---@type nx_console.NeoTree.NodeExtra
    extra = {
      type = types.node_types.NxTargetGroup,
      project_configuration = nx_node.projectConfiguration,
      project_name = nx_node.projectName,
    },

    children = {},

    path = nx_node.dir,
    is_reveal_target = true,
    contains_reveal_target = true,
  }
end

---@param nx_node nx_console.TreeNode
---@param group_name string
---@param target_name string
---@param config_name string?
---@return nx_console.NeoTree.TreeNode
M.create_target_node = function(nx_node, group_name, target_name, config_name)
  ---@type nx_console.NeoTree.TreeNode
  return {
    id = create_node_id(nx_node.projectName, group_name, target_name, config_name),
    name = config_name or target_name,
    type = "file",

    extra = {
      type = types.node_types.NxTarget,
      project_name = nx_node.projectName,
      target_name = target_name,
      configuration = config_name,
    },

    children = {},

    path = nx_node.dir,
    is_reveal_target = true,
    contains_reveal_target = true,
  }
end

return M
