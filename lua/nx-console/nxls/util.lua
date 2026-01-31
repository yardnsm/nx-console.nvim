local M = {}

--- Get the root path of the Nx workspace
--- @param path? string Path to check (defaults to cwd)
--- @return string | nil
function M.get_nx_workspace_root(path)
  path = path or vim.fn.getcwd()
  local nx_json = vim.fs.root(path, "nx.json")
  return nx_json
end

--- Check if we're in an Nx workspace (has nx.json)
---@param path? string Path to check (defaults to cwd)
---@return boolean
function M.is_nx_workspace(path)
  return M.get_nx_workspace_root(path) ~= nil
end

return M
