---@module 'snacks'

---@param opts nx_console.Picker.Options
return function(opts)
  local Snacks = Snacks or require("snacks")

  Snacks.picker.pick({
    title = opts.prompt,

    finder = function()
      ---@type snacks.picker.finder.Item[]
      local items = {}
      for _, item in ipairs(opts.items) do
        table.insert(items, {
          text = item.display, -- Must be a string
          item = item, -- Original item data
        })
      end
      return items
    end,

    format = function(item)
      -- Return table of highlight chunks
      return { { item.text } }
    end,

    layout = "select",

    actions = {
      confirm = function(picker, item)
        picker:close()
        if item and item.item then
          vim.schedule(function()
            opts.on_select(item.item)
          end)
        end
      end,
    },
  })
end
