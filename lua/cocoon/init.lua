---@class __cocoon_opts
---@field win? __cocoon_win_opts
---@field buf? __cocoon_buf_picker

---@class __cocoon
---@field opts __cocoon_opts
---@field picker __cocoon_buf_picker
local M = {}

function M.setup(opts)
    M.opts = opts or {}
    return M
end

M.picker = require("cocoon.picker").setup(M.opts)

return M
