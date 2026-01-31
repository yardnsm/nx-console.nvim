-- Adapted from project-graph.d.ts

---@class nx_console.ProjectGraphProjectNode
---@field type 'app' | 'e2e' | 'lib'
---@field name string
---@field data nx_console.ProjectConfiguration & { description?: string }
