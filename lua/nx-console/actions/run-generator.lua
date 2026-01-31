---Execute an Nx generator using the configured command runner
---@param generator_id string Full generator identifier (e.g., "collection:generator")
---@return nil
local function run_generator(generator_id)
  local config = require("nx-console.config")
  local cmd = "nx generate " .. generator_id
  config.options.command_runner(cmd)
end

return run_generator
