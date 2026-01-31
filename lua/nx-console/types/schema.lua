-- Adapted from schema.ts

---@alias nx_console.ItemTooltips table<string, string>

---@class nx_console.ItemsWithEnum
---@field enum string[]
---@field type string

---@class nx_console.CliOption
---@field name string
---@field originalName? string
---@field positional? number
---@field alias? string
---@field hidden? boolean
---@field deprecated? boolean | string

---@class nx_console.Option : nx_console.CliOption
---@field tooltip? string
---@field itemTooltips? nx_console.ItemTooltips
---@field items? string[]|nx_console.ItemsWithEnum
---@field aliases string[]
---@field isRequired boolean
---@field x_dropdown? 'projects'
---@field x_priority? 'important' | 'internal'
---@field x_hint? string

---@class nx_console.GeneratorCollectionInfo
---@field type 'generator'
---@field name string
---@field configPath string @ The path to the file that lists all generators in the collection.
---@field schemaPath string
---@field data? nx_console.Generator
---@field collectionName string

---@class nx_console.Generator
---@field collection string
---@field name string
---@field description string
---@field options? nx_console.Option[]
---@field type nx_console.GeneratorType
---@field aliases string[]

---@alias nx_console.GeneratorType
---| 'application'
---| 'library'
---| 'other'
