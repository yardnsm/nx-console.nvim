local telescope = require("telescope")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local nx_pickers = require("nx-console.pickers")
local picker_metadata = nx_pickers._metadata

local function nx_console_default_picker(opts)
  opts = opts or {}

  local select_action = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    -- Preserve telescope as the picker choice when calling from Telescope
    if selection and selection.value and selection.value.fn then
      selection.value.fn({ picker = "telescope" })
    end
  end

  pickers
    .new(opts, {
      prompt_title = "Nx Console",
      sorter = conf.generic_sorter(opts),
      finder = finders.new_table({
        results = picker_metadata,

        ---@param entry nx_console.Picker.Metadata
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name .. " " .. entry.desc,
          }
        end,
      }),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          select_action(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end

---@diagnostic disable-next-line:undefined-field
return telescope.register_extension({
  exports = {
    -- Default picker when running :Telescope nx-console
    nx_console = nx_console_default_picker,

    -- Individual pickers
    projects = nx_pickers.projects,
    targets = nx_pickers.targets,
    targets_current = nx_pickers.targets_current,
    generators = nx_pickers.generators,
  },
})
