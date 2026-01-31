---@param opts nx_console.Picker.Options
return function(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local select_action = function(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection and selection.value then
      opts.on_select(selection.value)
    end
  end

  pickers
    .new({}, {
      prompt_title = opts.prompt,

      finder = finders.new_table({
        results = opts.items,
        entry_maker = function(item)
          return {
            value = item,
            display = item.display,
            ordinal = item.ordinal,
          }
        end,
      }),

      sorter = conf.generic_sorter({}),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          select_action(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end
