local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

---@class nx_console.TargetInfo
---@field project string Project name
---@field target string Target name
---@field configuration? string Configuration name
---@field executor? string Executor/command

---@class nx_console.GetTargetsOptions
---@field project? string Filter targets by project name

--- Get targets from the workspace
--- Note: This function should be called from within an async context (async.run)
---@async
---@param opts? nx_console.GetTargetsOptions Options
---@return nx_console.TargetInfo[] | nil targets List of targets
---@return string | nil error Error message if failed
local function get_targets(opts)
  opts = opts or {}

  local nxls_client = nxls.ensure_client_started_async()

  if not nxls_client:is_running() then
    return nil, "Nxls client is not running"
  end

  -- Get workspace to access all targets
  local err, result = nxls_client:request_async(types.request_types.NxWorkspaceRequest, { reset = false })

  if err then
    return nil, err
  end

  if not result or not result.projectGraph or not result.projectGraph.nodes then
    return {}, nil
  end

  local targets = {}

  -- Iterate through projects and their targets
  for project_name, node in pairs(result.projectGraph.nodes) do
    -- Filter by project if specified
    if not opts.project or project_name == opts.project then
      local project_targets = node.data and node.data.targets or {}

      for target_name, target_config in pairs(project_targets) do
        -- Add base target
        table.insert(targets, {
          project = project_name,
          target = target_name,
          executor = target_config.executor or target_config.command,
        })

        -- Add configurations
        if target_config.configurations then
          for config_name, _ in pairs(target_config.configurations) do
            table.insert(targets, {
              project = project_name,
              target = target_name,
              configuration = config_name,
              executor = target_config.executor or target_config.command,
            })
          end
        end
      end
    end
  end

  -- Sort by project, then target, then configuration
  table.sort(targets, function(a, b)
    if a.project ~= b.project then
      return a.project < b.project
    end
    if a.target ~= b.target then
      return a.target < b.target
    end
    if a.configuration and b.configuration then
      return a.configuration < b.configuration
    end
    return not a.configuration
  end)

  return targets, nil
end

return get_targets
