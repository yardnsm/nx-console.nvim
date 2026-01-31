local log = require("nx-console.log")

local M = {}

---@class nx_console.Picker.Item
---@field id string Unique identifier
---@field display string Display text
---@field ordinal string Text to match against
---@field data table Additional data

---@class nx_console.Picker.Options
---@field prompt string Prompt text
---@field items nx_console.Picker.Item[] List of items to pick from
---@field on_select fun(item: nx_console.Picker.Item) Callback when item is selected

---@alias nx_console.Picker.Adapter fun(opts: nx_console.Picker.Options)

---@type table<nx_console.Picker.AdapterType, nx_console.Picker.Adapter>
M.adapters = {
  telescope = require("nx-console.pickers.adapters.telescope"),
  snacks = require("nx-console.pickers.adapters.snacks"),
  fzf = require("nx-console.pickers.adapters.fzf"),
}

---@param adapter_type? nx_console.Picker.AdapterType
---@return nx_console.Picker.Adapter | nil
---@return string | nil error
function M.get_adapter(adapter_type)
  local config = require("nx-console.config").options

  -- Use explicitly passed picker name first
  local target_adapter = adapter_type or config.picker

  if target_adapter then
    if M.adapters[target_adapter] then
      return M.adapters[target_adapter], nil
    end
  end

  -- Auto-detect available pickers (order: telescope, snacks, fzf)
  if pcall(require, "telescope") then
    return M.adapters.telescope, nil
  end

  if pcall(require, "snacks") then
    return M.adapters.snacks, nil
  end

  if pcall(require, "fzf-lua") then
    return M.adapters.fzf, nil
  end

  return nil, "No picker available"
end

--- Show a picker with the given options
---@param opts nx_console.Picker.Options
---@param picker_name? nx_console.Picker.AdapterType
function M.pick(opts, picker_name)
  local adapter, err = M.get_adapter(picker_name)
  if not adapter then
    log.error(err or "No picker available")
    return
  end

  adapter(opts)
end

return M
