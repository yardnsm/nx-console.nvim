local async = require("plenary.async")

local util = require("nx-console.util")
local log = require("nx-console.log")

local get_projects = require("nx-console.workspace.get-projects")

--- Show picker to select a project
---@param opts? table Options (can include 'picker' field to override picker: "telescope", "fzf", "snacks")
return function(opts)
  opts = opts or {}
  local picker = opts.picker

  async.run(function()
    local projects, err = get_projects()
    if err then
      vim.schedule(function()
        log.error("Failed to get projects: " .. err)
      end)
      return
    end

    if not projects or #projects == 0 then
      vim.schedule(function()
        log.warn("No projects found in workspace")
      end)
      return
    end

    local items = vim.tbl_map(function(project)
      return {
        id = project.name,
        display = project.name .. " (" .. (project.projectType or "unknown") .. ")",
        ordinal = project.name,
        data = project,
      }
    end, projects)

    vim.schedule(function()
      require("nx-console.pickers.core").pick({
        prompt = "Nx Projects",
        items = items,
        on_select = function(item)
          require("nx-console.pickers").targets({ project = item.id, picker = picker })
        end,
      }, picker)
    end)
  end, util.noop)
end
