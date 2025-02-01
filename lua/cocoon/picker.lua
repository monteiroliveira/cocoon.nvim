local buffer = require("cocoon.buffer")
local window = require("cocoon.window")
local utils = require("cocoon.utils")
local proc = require("cocoon.proc")

local M = {}

M.opts = {}
M.window_mgr = window

function M:unpick()
    local bufnr = vim.api.nvim_win_get_buf(0)
    if buffer.is_cocoon_buf(bufnr) then
        vim.api.nvim_win_hide(0)
    end
end

function M:pick(bufnr)
    if buffer.is_cocoon_buf(bufnr) then
        M.window_mgr:create_window(bufnr)
    end
end

function M:pick_first()
    local first_bufnr = buffer.get_first_buf()
    if first_bufnr ~= nil then
        vim.fn.bufload(first_bufnr)
        M.window_mgr:create_window(first_bufnr)
    end
end

function M:pick_new()
    local bufnr, winrn = M.window_mgr:create_window_with_buf(M.opts.buf)
    if bufnr then
        proc.create_term_session(bufnr, vim.o.shell)
    end
end

function M.setup(opts)
    if opts then
        M.opts = utils.merge_tables(M.opts, opts)
    end
    M.window_mgr = window.setup(M.opts.win)
    return M
end

return M
