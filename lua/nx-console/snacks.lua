local picker_metadata = require("nx-console.pickers")._metadata

local M = {}

---@type snacks.picker.Config
M.source = {
  title = "Nx Console",

  finder = function()
    ---@type snacks.picker.finder.Item[]
    local items = {}
    for _, item in ipairs(picker_metadata) do
      table.insert(items, {
        text = item.name .. " " .. item.desc,
        item = item,
      })
    end
    return items
  end,

  format = function(item)
    return { { item.text } }
  end,

  layout = "vscode",

  actions = {
    ---@param picker snacks.Picker
    ---@param item snacks.picker.Item
    confirm = function(picker, item)
      picker:close()

      ---@type nx_console.Picker.Metadata
      local selected = item.item
      if selected then
        vim.schedule(function()
          selected.fn({ picker = "snacks" })
        end)
      end
    end,
  },
}

return M
