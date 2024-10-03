local M = {}

---@return table
function M.merge_tables(origin, target)
    for k, v in pairs(target) do origin[k] = v end
    return origin
end

return M
