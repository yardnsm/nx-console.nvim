local log = require("nx-console.log")

return {
  fn = function()
    local nxls = require("nx-console.nxls").get_nxls()

    if nxls:is_running() then
      log.warn("nxls is already running")
      return
    end

    nxls:start_client(vim.fn.getcwd())
    log.info("Starting nxls...")
  end,
}
