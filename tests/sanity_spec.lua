local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

describe("nx-console.nvim sanity test", function()
  it("should download nxls and use the nxls language server", function()
    -- Change to the nx-console submodule directory which has nx.json
    vim.fn.chdir("deps/nx-console")

    nxls.ensure_client_started(function(nxls_client)
      assert.is_true(nxls_client:is_running())

      local response, err = nxls_client:get_client():request_sync(types.request_types.NxVersionRequest, {})

      assert.is_nil(err)
      assert.is_table(response)

      assert.is_string(response and response["result"]["full"])
      assert.is_number(response and response["result"]["major"])
      assert.is_number(response and response["result"]["minor"])
    end)
  end)
end)
