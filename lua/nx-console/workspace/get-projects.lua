local nxls = require("nx-console.nxls.client")
local types = require("nx-console.nxls.types")

---@class nx_console.Project
---@field name string Project name
---@field root string Project root path
---@field projectType? 'application' | 'library' Project type

--- Get all projects in the workspace
--- Note: This function should be called from within an async context (async.run)
---@async
---@return nx_console.Project[] | nil projects List of projects
---@return string | nil error Error message if failed
local function get_projects()
  local client_inst = nxls.get_nxls()

  if not client_inst:is_running() then
    return nil, "Nxls client is not running"
  end

  -- Use the workspace request to get all projects
  local err, result = client_inst:request_async(types.request_types.NxWorkspaceRequest, { reset = false })

  if err then
    return nil, err
  end

  if not result or not result.projectGraph or not result.projectGraph.nodes then
    return {}, nil
  end

  -- Convert project graph nodes to project list
  local projects = {}
  for name, node in pairs(result.projectGraph.nodes) do
    table.insert(projects, {
      name = name,
      root = node.data and node.data.root or "",
      projectType = node.type,
    })
  end

  -- Sort by name
  table.sort(projects, function(a, b)
    return a.name < b.name
  end)

  return projects, nil
end

return get_projects
