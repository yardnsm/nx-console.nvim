-- Adapted from workspace-json-project-json.d.ts

---@class nx_console.ProjectsConfigurations
---@field version number
---@field projects table<string, nx_console.ProjectConfiguration>

---@alias nx_console.ProjectType 'library' | 'application'

---@class nx_console.ProjectConfiguration
---@field name? string
---@field targets? table<string, nx_console.TargetConfiguration>
---@field root string
---@field sourceRoot? string
---@field projectType? nx_console.ProjectType
---@field generators? table<string, table<string, any>>
---@field implicitDependencies? string[]
---@field namedInputs? table<string, (string | nx_console.InputDefinition)[]>
---@field tags? string[]
---@field release? { version?: { generator: string, generatorOptions: any } }
---@field metadata? nx_console.ProjectMetadata

---@class nx_console.ProjectMetadata
---@field description? string
---@field technologies? string[]
---@field targetGroups? table<string, string[]>
---@field owners? table<string, { ownedFiles: { files: string[] | '"*"', fromConfig?: { filePath: string, location: { startLine: number, endLine: number } } }[] }>
---@field js? { packageName: string, packageExports?: any, packageMain?: string, isInPackageManagerWorkspaces?: boolean }

---@class nx_console.TargetMetadata
---@field [string] any
---@field description? string
---@field technologies? string[]
---@field nonAtomizedTarget? string
---@field help? { command: string, example: { options?: table<string, any>, args?: string[] } }

---@class nx_console.TargetDependencyConfig
---@field projects? string[] | string
---@field dependencies? boolean
---@field target string
---@field params? '"ignore"' | '"forward"'

---@alias nx_console.InputDefinition
---| { input: string, projects: string | string[] }
---| { input: string, dependencies: true }
---| { input: string }
---| { fileset: string }
---| { runtime: string }
---| { externalDependencies: string[] }
---| { dependentTasksOutputFiles: string, transitive?: boolean }
---| { env: string }

---@class nx_console.TargetConfiguration
---@field executor? string
---@field command? string
---@field outputs? string[]
---@field dependsOn? (nx_console.TargetDependencyConfig | string)[]
---@field inputs? (nx_console.InputDefinition | string)[]
---@field options? any
---@field configurations? table<string, any>
---@field defaultConfiguration? string
---@field cache? boolean
---@field metadata? nx_console.TargetMetadata
---@field parallelism? boolean
---@field syncGenerators? string[]
