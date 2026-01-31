---@param opts nx_console.Picker.Options
return function(opts)
  local fzf = require("fzf-lua")

  local items_map = {}
  local display_items = {}

  for _, item in ipairs(opts.items) do
    items_map[item.display] = item
    table.insert(display_items, item.display)
  end

  fzf.fzf_exec(display_items, {
    prompt = opts.prompt .. "> ",
    actions = {
      ["default"] = function(selected)
        if selected and selected[1] then
          local item = items_map[selected[1]]
          if item then
            opts.on_select(item)
          end
        end
      end,
    },
  })
end
