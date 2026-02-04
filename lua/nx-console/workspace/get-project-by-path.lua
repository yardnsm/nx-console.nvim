local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

---@class nx_console.NxProjectByPathRequestOptions
---@field projectPath string

---@alias nx_console.NxProjectByPathResponse nx_console.ProjectConfiguration

--- Get project configuration by file path
--- Note: This function should be called from within an async context (async.run)
---@async
---@param options? nx_console.NxProjectByPathRequestOptions Options
---@return nx_console.NxProjectByPathResponse | nil project Project configuration
---@return string | nil error Error message if failed
local function get_project_by_path(options)
  local nxls_client = nxls.ensure_client_started_async()

  if not nxls_client:is_running() then
    return nil, "Nxls client is not running"
  end

  local err, result = nxls_client:request_async(types.request_types.NxProjectByPathRequest, options or {})

  if err then
    return nil, err
  end

  return result, nil
end

return get_project_by_path
