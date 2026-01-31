local log = require("nx-console.log")

return {
  fn = function()
    local download = require("nx-console.nxls.download")

    log.info("Downloading nxls...")

    download.ensure_downloaded(function(err)
      if err then
        log.error("Download failed: " .. err)
      else
        log.info("nxls downloaded successfully")
      end
    end)
  end,
}
