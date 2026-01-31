---Utility functions for building Nx ID strings from structured data
local M = {}

---Build a target ID string from components
---@param project string The project name
---@param target string The target name
---@param configuration? string Optional configuration name
---@return string Full target ID (e.g., "project:target:configuration")
function M.build_target_id(project, target, configuration)
  local id = project .. ":" .. target
  if configuration then
    id = id .. ":" .. configuration
  end
  return id
end

---Build a generator ID string from components
---@param name string The generator name
---@return string Full generator ID (e.g., "collection:generator")
function M.build_generator_id(name)
  return name
end

return M
