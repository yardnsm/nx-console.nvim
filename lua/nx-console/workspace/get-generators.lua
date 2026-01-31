local nxls = require("nx-console.nxls.client")
local types = require("nx-console.nxls.types")

---@class nx_console.NxGeneratorsRequestOptions
---@field includeHidden? boolean
---@field includeNgAdd? boolean

---@alias nx_console.NxGeneratorsResponse nx_console.GeneratorCollectionInfo[]

--- Get available generators from the workspace
--- Note: This function should be called from within an async context (async.run)
---@async
---@param options? nx_console.NxGeneratorsRequestOptions Options
---@return nx_console.NxGeneratorsResponse | nil generators List of generator collections
---@return string | nil error Error message if failed
local function get_generators(options)
  local client_inst = nxls.get_nxls()

  if not client_inst:is_running() then
    return nil, "Nxls client is not running"
  end

  local err, result = client_inst:request_async(types.request_types.NxGeneratorsRequest, options or {})

  if err then
    return nil, err
  end

  return result, nil
end

return get_generators
