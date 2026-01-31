local nxls = require("nx-console.nxls")
local types = require("nx-console.nxls.types")

describe("nx-console.nvim sanity test", function()
  it("should download nxls and use the nxls language server", function()
    -- Change to the nx-console submodule directory which has nx.json
    vim.fn.chdir("deps/nx-console")

    local done = false
    local test_error = nil

    nxls.ensure_client_started(function(nxls_client)
      local success, err = pcall(function()
        assert.is_true(nxls_client:is_running())

        local response, err = nxls_client:get_client():request_sync(types.request_types.NxVersionRequest, {}, 50000)

        assert.is_nil(err)
        assert.is_table(response)

        assert.is_string(response and response["result"]["full"])
        assert.is_number(response and response["result"]["major"])
        assert.is_number(response and response["result"]["minor"])
      end)

      if not success then
        test_error = err
      end
      done = true
    end)

    -- Wait for the callback to complete (max 30 seconds)
    vim.wait(30000, function()
      return done
    end, 100)

    -- Check if we timed out
    assert.is_true(done, "Test timed out waiting for nxls client to start")

    -- If there was an error in the callback, raise it
    if test_error then
      error(test_error)
    end
  end)
end)
