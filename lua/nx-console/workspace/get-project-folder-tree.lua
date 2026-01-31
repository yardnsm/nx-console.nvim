local nxls = require("nx-console.nxls.client")
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
  local client_inst = nxls.get_nxls()

  if not client_inst:is_running() then
    return nil, "Nxls client is not running"
  end

  local err, result = client_inst:request_async(types.request_types.NxProjectFolderTreeRequest, {})
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
