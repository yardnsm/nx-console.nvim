local M = {}

M.projects = require("nx-console.pickers.projects")
M.targets = require("nx-console.pickers.targets")
M.targets_current = require("nx-console.pickers.targets_current")
M.generators = require("nx-console.pickers.generators")

---@alias nx_console.Picker.AdapterType "telescope" | "fzf" | "snacks" | nil

---@class nx_console.Picker.Metadata
---@field name string
---@field fn fun(opts: { picker?: nx_console.Picker.AdapterType }): nil
---@field desc string

---@type nx_console.Picker.Metadata[]
M._metadata = {
  { name = "Projects", fn = M.projects, desc = "List all Nx projects" },
  { name = "Targets", fn = M.targets, desc = "List all Nx targets" },
  { name = "Targets (Current)", fn = M.targets_current, desc = "List targets for current file's project" },
  { name = "Generators", fn = M.generators, desc = "List all Nx generators" },
}

return M
