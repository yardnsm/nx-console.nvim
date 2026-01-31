local M = {}

-- Path constants
M.nxls_data_dir = vim.fn.stdpath("data") .. "/nx-console/nxls"
M.nxls_download_path = M.nxls_data_dir .. "/main.js"
M.nxls_version_file = M.nxls_data_dir .. "/version.txt"

--- Ensure the nxls data directory exists
function M.ensure_dir_exists()
  vim.fn.mkdir(M.nxls_data_dir, "p")
end

--- Get the currently installed nxls version
---@return string | nil revision The installed revision SHA, or nil if not installed
function M.get_installed_version()
  if vim.fn.filereadable(M.nxls_version_file) ~= 1 then
    return nil
  end

  local lines = vim.fn.readfile(M.nxls_version_file)
  if #lines == 0 then
    return nil
  end

  -- Trim whitespace and return the first line
  return vim.trim(lines[1])
end

--- Set the installed nxls version
---@param revision string The revision SHA to write
function M.set_installed_version(revision)
  vim.fn.writefile({ revision }, M.nxls_version_file)
end

return M
