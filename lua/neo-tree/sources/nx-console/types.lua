local M = {}

---@enum nx_console.NeoTree.NodeType
M.node_types = {
  NxStatus = "NxStatus",
  NxDirectory = "NxDirectory",
  NxProject = "NxProject",
  NxTarget = "NxTarget",
  NxTargetGroup = "NxTargetGroup",
}

---@class nx_console.NeoTree.NodeExtra
---@field type nx_console.NeoTree.NodeType
---@field project_configuration? nx_console.ProjectGraphProjectNode
---@field project_name? string
---@field target_name? string
---@field configuration? string

---@class nx_console.NeoTree.TreeNode : neotree.FileItem
---@field extra nx_console.NeoTree.NodeExtra
---@field children table<nx_console.NeoTree.TreeNode>

M.Ungrouped = "__nx_console_ungrouped__"

return M
