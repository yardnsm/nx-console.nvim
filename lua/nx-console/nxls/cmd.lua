local config = require("nx-console.config")
local files = require("nx-console.nxls.download.files")

local M = {}

--- Get the nxls command to start the language server
---@return string[] cmd Command array to start nxls
M.get_nxls_cmd = function()
  local opts = config.options

  -- Use the downloaded main.js
  local nxls_bundle = opts.nxls.nxls_path or files.nxls_download_path

  -- Check if main.js exists
  if vim.fn.filereadable(nxls_bundle) ~= 1 then
    error("nxls not found at: " .. nxls_bundle .. ". Run :NxConsole download or set nxls.nxls_path in your config.")
  end

  local cmd = {}
  vim.list_extend(cmd, opts.nxls.node_command)
  vim.list_extend(cmd, { nxls_bundle, "--stdio" })

  return cmd
end

return M
