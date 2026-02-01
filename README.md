# nx-console.nvim

[Nx Console](https://github.com/nrwl/nx-console) for Neovim — powered by the official `nxls` language server, the same one used in VS Code and JetBrains IDEs.

> **⚠️ Work in Progress**: This plugin is under active development. Features and APIs may change.

![nx-console.nvim](https://github.com/user-attachments/assets/a77f32c2-b4a2-4b45-a76a-dbec086e1e8c)

## Features

- **Integrated Language Server**: Full `nxls` LSP integration for Nx workspace intelligence
- **Interactive Pickers**: Browse and execute projects, targets, and generators
  - Telescope support
  - fzf-lua support
  - Snacks.nvim support
- **Neo-tree Integration**: Visual workspace navigation with a dedicated tree view
- **Automatic Binary Management**: Downloads and updates `nxls` automatically, using a pre-built binary
- **LSP Features**: Full language server support for `nx.json` and `project.json` files
- **Run Targets**: Execute Nx targets directly from Neovim with customizable runners

## How it Works

nx-console.nvim uses the [`nxls` language server](https://github.com/nrwl/nx-console/tree/master/apps/nxls) from the official Nx Console project. This is the same language server that powers Nx Console in VS Code and JetBrains IDEs, allowing nx-console.nvim to provide the same functionality.

**Language Server Integration:**

- nx-console.nvim automatically downloads and manages the `nxls` binary (or you can provide your own)
- `nxls` runs as a standard LSP server, providing workspace intelligence via the Language Server Protocol
- All workspace data (projects, targets, generators) is fetched through LSP requests

By using the official language server, nx-console.nvim provides the same reliable Nx integration as the official IDE plugins, ensuring feature parity and compatibility with the latest Nx features.

## Requirements

- Neovim 0.11 or later
- Node.js 20 or later (for running `nxls`)
- Optional: One of the following pickers:
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua)
  - [snacks.nvim](https://github.com/folke/snacks.nvim)
- Optional: [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) for tree view integration

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yardnsm/nx-console.nvim",
  submodules = false,
  dependencies = {
    "nvim-lua/plenary.nvim",

    -- Optional: choose your preferred picker
    "nvim-telescope/telescope.nvim",  -- or "ibhagwan/fzf-lua" or "folke/snacks.nvim"

    -- Optional: for projects tree view
    "nvim-neo-tree/neo-tree.nvim",
  },

  opts = {
    -- Your configuration here (see Configuration section)
  },

  keys = {
    { "<leader>np", function() require("nx-console").pickers.projects() end, desc = "Nx Projects" },
    { "<leader>nt", function() require("nx-console").pickers.targets() end, desc = "Nx Targets" },
    { "<leader>nT", function() require("nx-console").pickers.targets_current() end, desc = "Nx Targets (current file)" },
    { "<leader>ng", function() require("nx-console").pickers.generators() end, desc = "Nx Generators" },
  },
}
```

## Configuration

nx-console.nvim works with zero configuration using sensible defaults - see all available options and their defaults [here](./lua/nx-console/config.lua).

### Neo-tree Integration

To use the Neo-tree source:

```lua
require("neo-tree").setup({
  sources = {
    "nx-console",
    "filesystem",
    "buffers",
    "git_status",
  },
  ["nx-console"] = {
    -- Auto-refresh when workspace changes (default: true)
    auto_refresh_on_workspace_change = true,
  },
})
```

### Command Runners

Command runners are responsible for executing Nx CLI commands when you run targets or generators from nx-console.nvim. Since Nx is a CLI tool, this plugin wraps command execution to integrate with your preferred terminal environment.

nx-console.nvim provides built-in runners and makes it easy to create custom ones:

**Built-in Runners:**

```lua
-- Snacks.nvim terminal runner (default)
-- Requires: https://github.com/folke/snacks.nvim
require("nx-console").setup({
  command_runner = require("nx-console.runners").snacks({
    auto_close = false,
    win = {
      position = "right",
      height = 0.4,
    },
  }),
})

-- yeet.nvim runner
-- Requires: https://github.com/samhh/yeet.nvim
require("nx-console").setup({
  command_runner = require("nx-console.runners").yeet(),
})
```

**Custom Runners:**

Create your own by providing a function that accepts a command string:

```lua
-- Simple shell execution
require("nx-console").setup({
  command_runner = function(cmd)
    vim.cmd("!" .. cmd)
  end,
})
```

The command string passed to runners is the full Nx CLI command (e.g., `nx run my-app:build --watch`). See `:help nx-console-runners` for more details.

## Usage

### Commands

nx-console.nvim provides the following commands:

- `:NxConsole start` - Start the nxls language server
- `:NxConsole stop` - Stop the nxls language server
- `:NxConsole refresh` - Refresh the Nx workspace (restarts nxls and clears daemon cache)
- `:NxConsole download` - Manually download/update the nxls binary

### Pickers

#### Using Telescope

```vim
:Telescope nx-console projects
:Telescope nx-console targets
:Telescope nx-console targets_current
:Telescope nx-console generators
```

#### Using Lua API

The Lua API works with all supported pickers:

```lua
-- List all projects
require("nx-console").pickers.projects()

-- List targets for a specific project
require("nx-console").pickers.targets({ project = "my-app" })

-- List targets for the current file's project
require("nx-console").pickers.targets_current()

-- List available generators
require("nx-console").pickers.generators()

-- Explicitly choose a picker
require("nx-console").pickers.projects({ picker = "fzf" })
require("nx-console").pickers.projects({ picker = "snacks" })
require("nx-console").pickers.projects({ picker = "telescope" })
```

### Neo-Tree

Once configured, navigate to the nx-console source in Neo-tree to browse your Nx workspace visually.

**Default mappings in the nx-console tree:**

- `<CR>` or `o` - Smart action:
  - On project/folder: Toggle expansion
  - On target: Run the target
- `R` - Force refresh the tree
- `?` - Show help
- `q` - Close window

## Documentation

For detailed documentation, see:

```vim
:help nx-console
```

---

## License

Apache 2.0 © [Yarden Sod-Moriah](http://ysm.sh/)

See [LICENSE](LICENSE) for details.
