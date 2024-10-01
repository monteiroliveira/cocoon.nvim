local buffer = require("cocoon.buffer")
local utils = require("cocoon.utils")

---@class __cocoon_win_opts
---@field title string
---@field title_pos string
---@field width integer
---@field height integer
---@field border string
---@field style string

---@class __cocoon_win
---@field opts __cocoon_win_opts
local M = {}

M.opts = {
    title = "Cocoon",
    title_pos = "center",
    width = vim.o.columns - 100,
    height = vim.o.lines - 20,
    border = "single",
    style = "minimal",
}

M.default_win_config = {
        relative = "editor",
        width = M.opts.width,
        height = M.opts.height,
        row = math.floor((vim.o.lines - M.opts.height) / 2),
        col = math.floor((vim.o.columns - M.opts.width) / 2),
        border = M.opts.border,
        title = M.opts.title,
        title_pos = M.opts.title_pos,
        style = M.opts.style,
}

---@param opts? __cocoon_win_opts
function M.setup(opts)
    if opts then
        M.opts = utils.merge_tables(M.opts, opts)
    end
    return M
end

---@return integer
---@param bufnr integer
function M:create_window(bufnr)
    return vim.api.nvim_open_win(bufnr, true, M.default_win_config)
end

---@return integer | nil
---@param opts? __cocoon_buf_opts
function M:create_window_with_buf(opts)
    local bufnr = buffer.setup(opts):create()
    if bufnr then
        return vim.api.nvim_open_win(bufnr, true, M.default_win_config)
    end
end

return M
