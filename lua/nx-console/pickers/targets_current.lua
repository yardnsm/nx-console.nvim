local async = require("plenary.async")

local util = require("nx-console.util")
local log = require("nx-console.log")

local get_project_by_path = require("nx-console.workspace.get-project-by-path")

---@param opts? { picker?: nx_console.Picker.AdapterType }
return function(opts)
  opts = opts or {}
  local picker = opts.picker
  local current_file = vim.fn.expand("%:p")

  async.run(function()
    local project, err = get_project_by_path({ projectPath = current_file })

    vim.schedule(function()
      if err then
        log.error("Failed to get project: " .. err)
        return
      end

      if project and project.name then
        local targets_picker = require("nx-console.pickers.targets")
        targets_picker({ project = project.name, picker = picker })
      end
    end)
  end, util.noop)
end
