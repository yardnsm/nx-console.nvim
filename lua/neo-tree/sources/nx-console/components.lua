local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

local M = {}

---@type table<nx_console.NeoTree.NodeType, { icon: string, icon_hl: string, text_hl: string }>
local type_configurations = {
  NxStatus = {
    icon = "C",
    icon_hl = highlights.DIRECTORY_ICON,
    text_hl = highlights.DIRECTORY_NAME,
  },
  NxDirectory = {
    icon = nil,
    icon_hl = highlights.DIRECTORY_ICON,
    text_hl = highlights.DIRECTORY_NAME,
  },
  NxProject = {
    icon = "",
    icon_hl = highlights.DIRECTORY_ICON,
    text_hl = highlights.DIRECTORY_NAME,
  },
  NxTarget = {
    icon = "󱍔",
    icon_hl = highlights.FILE_ICON,
    text_hl = highlights.FILE_NAME,
  },
  NxTargetGroup = {
    icon = "",
    icon_hl = highlights.DIRECTORY_ICON,
    text_hl = highlights.DIRECTORY_NAME,
  },
}

---@param config neotree.Component.Common.Icon
---@param node neotree.FileNode
---@param state neotree.StateWithTree
M.icon = function(config, node, state)
  ---@diagnostic disable-next-line: undefined-field
  local padding = config.padding or " "

  ---@type nx_console.NeoTree.NodeType
  local type = node.extra.type

  local icon = type_configurations[type].icon or config.default or " "
  local highlight = type_configurations[type].icon_hl or config.highlight or highlights.FILE_ICON

  -- Special case for folders
  if type == "NxDirectory" then
    if node:is_expanded() then
      icon = config.folder_open or "-"
    else
      icon = config.folder_closed or "+"
    end
  end

  return {
    text = icon .. padding,
    highlight = highlight,
  }
end

---@param config neotree.Component.Common.Name
---@param node neotree.FileNode
---@param state neotree.StateWithTree
M.name = function(config, node, state)
  ---@type nx_console.NeoTree.NodeType
  local type = node.extra.type

  local highlight = type_configurations[type].text_hl or config.highlight or highlights.FILE_NAME

  -- Special case for root dir
  if node:get_depth() == 1 then
    highlight = highlights.ROOT_NAME
  end

  return {
    text = node.name,
    highlight = highlight,
  }
end

return vim.tbl_deep_extend("force", common, M)
