local log = require("nx-console.log")

return {
  fn = function()
    local nxls = require("nx-console.nxls").get_nxls()

    if not nxls:is_running() then
      log.warn("nxls is not running. Start it first with :NxConsole start")
      return
    end

    nxls:refresh_workspace()
  end,
}
