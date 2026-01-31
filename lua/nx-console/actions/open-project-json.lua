---Open project.json for a project
---@param project_root string The project root path (relative to workspace)
---@return nil
local function open_project_json(project_root)
  local log = require("nx-console.log")
  local project_json = vim.fn.getcwd() .. "/" .. project_root .. "/project.json"

  if vim.fn.filereadable(project_json) ~= 1 then
    log.warn("project.json not found at: " .. project_json)
    return
  end

  -- Use pcall to safely open the file
  local ok, err = pcall(function()
    vim.cmd.edit(project_json)
  end)

  if not ok then
    log.error("Failed to open project.json: " .. tostring(err))
  end
end

return open_project_json
