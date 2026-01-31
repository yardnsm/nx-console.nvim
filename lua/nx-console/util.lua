local M = {}

--- No-operation function (used as async callback)
M.noop = function() end

M.group_by = function(tbl, predicate)
  local result = {}
  for _, value in ipairs(tbl) do
    local key = predicate(value)
    if not result[key] then
      result[key] = {}
    end
    table.insert(result[key], value)
  end
  return result
end

return M
