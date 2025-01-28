local M = {}

function M.setup(opts)
    M.opts = opts or {}
    return M
end

M.picker = require("cocoon.picker").setup(M.opts)

return M
