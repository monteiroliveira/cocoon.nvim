local utils = require("cocoon.utils")
local augroup = require("cocoon.augroup")

local LIST_ACTIVE_BUFFERS = {}
local BUFFER_NAME = "__coccon_buf__"
local BUFFER_ID = 0

local M = {}

M.opts = {
    limit = 9,
}

function M.setup(opts)
    if opts then
        M.opts = utils.merge_tables(M.opts, opts)
    end
    return M
end

function M.create()
    if not string.find(vim.api.nvim_buf_get_name(0), BUFFER_NAME) then
        if (BUFFER_ID + 1) <= M.opts.limit then
            BUFFER_ID = BUFFER_ID + 1
            local bufnr = vim.api.nvim_create_buf(true, true) -- For debug reasons

            M:_set_buf_name(bufnr)
            M:_register_buf_keymaps(bufnr)
            M:_register_buf_options(bufnr)
            M:_register_buf_autocmds(bufnr)

            table.insert(LIST_ACTIVE_BUFFERS, bufnr)

            return bufnr
        end
    end
end

function M:_set_buf_name(bufnr)
    local name = BUFFER_NAME .. BUFFER_ID
    vim.api.nvim_buf_set_name(bufnr, name)
end

function M.is_cocoon_buf(bufnr)
    local set = {}
    for _, v in pairs(LIST_ACTIVE_BUFFERS) do
        set[v] = true
    end
    if set[bufnr] then
        return true
    end
    return false
end

function M.buf_list_length()
    local count = 0
    for _ in pairs(LIST_ACTIVE_BUFFERS) do
        count = count + 1
    end
    return count
end

function M.get_first_buf()
    if M.buf_list_length() > 0 then
        return LIST_ACTIVE_BUFFERS[1]
    end
end

function M:_remove_buf_from_list(bufnr)
    if not bufnr then
        return nil
    end
    for i, v in ipairs(LIST_ACTIVE_BUFFERS) do
        if v == bufnr then
            table.remove(LIST_ACTIVE_BUFFERS, i)
        end
    end
end

function M:_register_buf_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true, noremap = true }
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

    vim.keymap.set("n", "q", function()
        local windows = vim.fn.win_findbuf(bufnr)
        local winid = windows[1] -- Dummy + 999999999
        pcall(vim.api.nvim_win_close, winid, true)
    end, opts)

    vim.keymap.set("t", "<C-q>", function()
        local windows = vim.fn.win_findbuf(bufnr)
        local winid = windows[1] -- Dummy + 999999999
        pcall(vim.api.nvim_win_close, winid, true)
    end, opts)

    vim.keymap.set({ "n", "t" }, "<C-k>", function()
        local windows = vim.fn.win_findbuf(bufnr)
        local winid = windows[1] -- Dummy + 999999999
        pcall(vim.api.nvim_win_close, winid, true)
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        M:_remove_buf_from_list(bufnr)
    end, opts)
end

function M:_register_buf_autocmds(bufnr)
    local cocoon_pattern = BUFFER_NAME .. "*"
    vim.api.nvim_create_autocmd("BufLeave", {
        once = true,
        pattern = cocoon_pattern,
        callback = function() -- Unload buffer if leaving (C-k delete the buffer)
            vim.api.nvim_buf_delete(bufnr, { unload = true })
        end,
    })
end

function M:_register_buf_options(bufnr)
    local opts = { buf = bufnr }
    vim.api.nvim_set_option_value("buftype", "nofile", opts)
    vim.api.nvim_set_option_value("filetype", "cocoon", opts)
end

return M
