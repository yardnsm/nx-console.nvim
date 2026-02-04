local async = require("plenary.async")

local log = require("nx-console.log")
local util = require("nx-console.util")
local actions = require("nx-console.actions")

local nx_id_builder = require("nx-console.util.nx-id-builder")
local get_generators = require("nx-console.workspace.get-generators")

--- Show picker to select a generator
---@param opts? { picker?: string } Options (can include 'picker' field to override picker)
return function(opts)
  opts = opts or {}
  local picker = opts.picker

  -- Ensure nxls client is started before running picker
  async.run(function()
    local generators, err = get_generators()
    if err then
      vim.schedule(function()
        log.error("Failed to get generators: " .. err)
      end)
      return
    end

    if not generators or #generators == 0 then
      vim.schedule(function()
        log.warn("No generators found in workspace")
      end)
      return
    end

    local items = vim.tbl_map(function(generator)
      local id = nx_id_builder.build_generator_id(generator.name)
      local display = id
      if generator.data.description then
        display = display .. " - " .. generator.data.description
      end

      return {
        id = id,
        display = display,
        ordinal = id,
        data = { generator = generator },
      }
    end, generators)

    vim.schedule(function()
      require("nx-console.pickers.core").pick({
        prompt = "Nx Generators",
        items = items,
        on_select = function(item)
          actions.run_generator(item.id)
        end,
      }, picker)
    end)
  end, util.noop)
end
