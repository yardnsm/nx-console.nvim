local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

function M.check()
  start("nx-console.nvim")

  if vim.fn.has("nvim-0.11") == 1 then
    ok("Using Neovim >= 0.11")
  else
    error("Neovim >= 0.11 is required")
    return
  end

  local config = require("nx-console.config")
  local files = require("nx-console.nxls.download.files")

  -- Check nxls binary
  local nxls_path = config.options.nxls.nxls_path or files.nxls_download_path

  if vim.fn.filereadable(nxls_path) == 1 then
    ok(string.format("nxls binary found: %s", nxls_path))

    if not config.options.nxls.nxls_path then
      local installed_version = files.get_installed_version()
      if installed_version then
        info(string.format("Installed version: %s", installed_version))
      end
    end
  else
    warn(string.format("nxls binary not found at: %s", nxls_path))
  end

  -- Show target revision
  local revision = require("nx-console.nxls.revision")
  local target_revision = revision.get()
  info(string.format("Target revision: %s", target_revision))

  -- Check if nxls is running
  local client = require("nx-console.nxls.client")
  local nxls = client.get_nxls()

  if nxls:is_running() then
    ok("nxls is running")
    info(string.format("Client ID: %d", nxls:get_client().id))
  else
    info("nxls is not running (use :NxConsole start to start it)")
  end
end

return M
