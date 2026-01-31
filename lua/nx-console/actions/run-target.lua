---Execute an Nx target using the configured command runner
---@param target string|{ project: string, target: string, configuration?: string } Target ID string or structured data
---@return nil
local function run_target(target)
  local config = require("nx-console.config")
  local cmd

  if type(target) == "string" then
    -- String format: "project:target:configuration"
    cmd = "nx run " .. target
  else
    -- Structured format: { project, target, configuration }
    local nx_id_builder = require("nx-console.util.nx-id-builder")
    local id = nx_id_builder.build_target_id(target.project, target.target, target.configuration)
    cmd = "nx run " .. id
  end

  config.options.command_runner(cmd)
end

return run_target
