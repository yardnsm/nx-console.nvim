local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

---@class nx_console.NxVersion
---@field major number
---@field minor number
---@field patch number

--- Get the Nx version from the workspace
--- Note: This function should be called from within an async context (async.run)
---@async
---@return nx_console.NxVersion | nil version The Nx version
---@return string | nil error Error message if failed
local function get_nx_version()
  local nxls_client = nxls.ensure_client_started_async()

  if not nxls_client:is_running() then
    return nil, "Nxls client is not running"
  end

  local err, result = nxls_client:request_async(types.request_types.NxVersionRequest, {})

  if err then
    return nil, err
  end

  return result, nil
end

return get_nx_version
