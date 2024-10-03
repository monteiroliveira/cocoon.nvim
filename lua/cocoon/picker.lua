local buffer = require("cocoon.buffer")
local window = require("cocoon.window")
local utils = require("cocoon.utils")

---@class __cocoon_buf_picker
---@field opts table
---@field window_mgr __cocoon_win
local M = {}

M.opts = {}
M.window_mgr = window

function M:unpick()
    local bufnr = vim.api.nvim_win_get_buf(0)
    if buffer.is_cocoon_buf(bufnr) then
        vim.api.nvim_win_hide(0)
    end
end

---@param bufnr integer
function M:pick(bufnr)
    if buffer.is_cocoon_buf(bufnr) then
        M.window_mgr:create_window(bufnr)
    end
end

function M:pick_first()
    local first_bufnr = buffer.get_first_buf()
    if first_bufnr ~= nil then
        M.window_mgr:create_window(first_bufnr)
    end
end

function M:pick_new()
    M.window_mgr:create_window_with_buf(M.opts.buf)
end

---@param opts? __cocoon_opts
function M.setup(opts)
    if opts then
        M.opts = utils.merge_tables(M.opts, opts)
    end
    M.window_mgr = window.setup(M.opts.win)
    return M
end

return M
