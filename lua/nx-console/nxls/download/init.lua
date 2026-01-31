local log = require("nx-console.log")
local config = require("nx-console.config")
local files = require("nx-console.nxls.download.files")
local revision = require("nx-console.nxls.revision")

local M = {}

--- Get the release URL for a specific nxls revision
---@param sha string The 40-char SHA
---@return string The release URL
function M.get_release_url(sha)
  local release_tag = "nxls-" .. sha
  return "https://github.com/yardnsm/nx-console.nvim/releases/download/" .. release_tag .. "/nxls.tar.gz"
end

--- Ensure nxls is downloaded and ready to use
---@param callback fun(err: string | nil)
function M.ensure_downloaded(callback)
  local target_revision = config.options.nxls.download.nxls_revision or revision.get()
  if not target_revision then
    callback("No nxls revision specified")
    return
  end

  -- Skip download if manual binary path is set
  if config.options.nxls.nxls_path then
    callback(nil)
    return
  end

  -- Ensure data directory exists
  files.ensure_dir_exists()

  -- Check if already downloaded
  local installed_version = files.get_installed_version()
  if installed_version == target_revision then
    log.debug("nxls " .. target_revision .. " already installed")
    callback(nil)
    return
  end

  -- Download the requested revision
  M.download_nxls(target_revision, callback)
end

--- Download and extract a specific nxls revision from GitHub releases
---@param target_revision string The 40-char SHA to download
---@param callback fun(err: string | nil)
function M.download_nxls(target_revision, callback)
  local release_url = M.get_release_url(target_revision)
  local tarball_path = files.nxls_data_dir .. "/nxls.tar.gz.tmp"

  log.info("Downloading nxls revision " .. target_revision .. "...")

  -- Download tarball using curl
  vim.system({
    "curl",
    "-L", -- Follow redirects
    "-f", -- Fail silently on HTTP errors
    "-o",
    tarball_path,
    release_url,
  }, {}, function(result)
    if result.code ~= 0 then
      local err_msg = "Failed to download nxls from " .. release_url
      if result.stderr and #result.stderr > 0 then
        err_msg = err_msg .. ": " .. result.stderr
      else
        err_msg = err_msg .. ". The release may not be published yet."
      end

      vim.schedule(function()
        log.error(err_msg)
        callback(err_msg)
      end)
      return
    end

    log.info("Extracting nxls...")

    -- Extract tarball to data directory
    vim.system({
      "tar",
      "-xzf",
      tarball_path,
      "-C",
      files.nxls_data_dir,
    }, {}, function(extract_result)
      if extract_result.code ~= 0 then
        local err_msg = "Failed to extract nxls"
        if extract_result.stderr and #extract_result.stderr > 0 then
          err_msg = err_msg .. ": " .. extract_result.stderr
        end

        vim.schedule(function()
          log.error(err_msg)
          callback(err_msg)
        end)
        return
      end

      vim.schedule(function()
        -- Delete temporary tarball
        vim.fn.delete(tarball_path)

        -- Mark version as installed
        files.set_installed_version(target_revision)

        log.info("nxls " .. target_revision .. " installed successfully")
        callback(nil)
      end)
    end)
  end)
end

return M
