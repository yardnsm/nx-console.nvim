local async = require("plenary.async")

local util = require("nx-console.util")
local log = require("nx-console.log")
local actions = require("nx-console.actions")

local nx_id_builder = require("nx-console.util.nx-id-builder")
local get_targets = require("nx-console.workspace.get-targets")

---@param opts? { project?: string, picker?: nx_console.Config.PickerOption }
return function(opts)
  opts = opts or {}
  local picker = opts.picker

  -- Ensure nxls client is started before running picker
  require("nx-console.nxls").ensure_client_started(function(nxls)
    async.run(function()
      if not nxls:is_running() then
        log.error("Nxls client is not running")
        return
      end

      local targets, err = get_targets(opts)
      if err then
        log.error("Failed to get targets: " .. err)
        return
      end

      if not targets or #targets == 0 then
        vim.schedule(function()
          local msg = opts.project and ("No targets found for project: " .. opts.project)
            or "No targets found in workspace"
          log.warn(msg)
        end)
        return
      end

      local items = vim.tbl_map(function(target)
        -- Build full ID (always includes project name)
        local id = nx_id_builder.build_target_id(target.project, target.target, target.configuration)

        -- Build display string (omit project name if filtering by specific project)
        local display
        if opts.project then
          -- Show only target name when filtering by specific project
          display = target.target
          if target.configuration then
            display = display .. ":" .. target.configuration
          end
        else
          -- Show full project:target when showing all targets
          display = id
        end

        -- Add executor info to display
        if target.executor then
          display = display .. " (" .. target.executor .. ")"
        end

        return {
          id = id,
          display = display,
          ordinal = display,
          data = target,
        }
      end, targets)

      vim.schedule(function()
        local prompt = opts.project and ("Targets for " .. opts.project) or "Nx Targets"

        require("nx-console.pickers.core").pick({
          prompt = prompt,
          items = items,
          on_select = function(item)
            actions.run_target(item.id)
          end,
        }, picker)
      end)
    end, util.noop)
  end)
end
