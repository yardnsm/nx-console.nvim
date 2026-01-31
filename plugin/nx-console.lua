-- vim: tw=78:

---@toc_entry Commands
---@tag nx-console-commands
---@text
--- # Commands ~
---
--- nx-console.nvim provides the following user commands:
---
--- `:NxConsole start` - Start the nxls language server
--- `:NxConsole stop` - Stop the nxls language server
--- `:NxConsole refresh` - Refresh the Nx workspace (restarts nxls and clears
---                        daemon cache)
--- `:NxConsole download` - Manually download/update the nxls binary
---

if vim.g.loaded_nx_console then
  return
end
vim.g.loaded_nx_console = true

local augroup = vim.api.nvim_create_augroup("NxConsoleSetup", { clear = true })

-- Register the :NxConsole command
vim.api.nvim_create_user_command("NxConsole", function(opts)
  require("nx-console.commands").execute(opts.fargs)
end, {
  nargs = 1,
  complete = function(arg_lead, cmd_line, cursor_pos)
    return require("nx-console.commands").complete(arg_lead, cmd_line, cursor_pos)
  end,
  desc = "Nx Console commands",
})

-- Auto start and attach on nx.json and project.json files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "json" },
  callback = function(ev)
    local filename = vim.fn.fnamemodify(ev.file, ":t")
    if filename ~= "nx.json" and filename ~= "project.json" then
      return
    end

    require("nx-console.nxls").ensure_client_attached(ev.buf)
  end,
  desc = "Attach nx-console to nx.json and project.json file",
})
