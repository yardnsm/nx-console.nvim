-- Adapted from project-folder-tree.d.ts

---@class nx_console.TreeNode
---@field dir string
---@field projectName? string
---@field projectConfiguration? nx_console.ProjectGraphProjectNode
---@field children string[]

---@alias nx_console.TreeMap table<string, nx_console.TreeNode>
