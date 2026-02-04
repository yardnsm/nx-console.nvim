local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

---@class nx_console.ProjectFolderTreeResponse
---@field roots nx_console.TreeNode[]
---@field serializedTreeMap {dir:string, node: nx_console.TreeNode}[]

---@class nx_console.MappedProjectFolderTreeResponse
---@field roots nx_console.TreeNode[]
---@field tree_map nx_console.TreeMap

--- Get the project folder tree structure
--- Note: This function should be called from within an async context (async.run)
---@async
---@return nx_console.MappedProjectFolderTreeResponse | nil tree Project folder tree
---@return string | nil error Error message if failed
local function get_project_folder_tree()
  local nxls_client = nxls.ensure_client_started_async()

  if not nxls_client:is_running() then
    return nil, "Nxls client is not running"
  end

  local err, result = nxls_client:request_async(types.request_types.NxProjectFolderTreeRequest, {})
  if err ~= nil then
    return nil, err
  end

  local tree_map = {}
  for _, n in ipairs(result.serializedTreeMap) do
    tree_map[n.dir] = n.node
  end

  return {
    roots = result.roots,
    tree_map = tree_map,
  }, nil
end

return get_project_folder_tree
