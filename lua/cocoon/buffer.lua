local utils = require("cocoon.utils")
local augroup = require("cocoon.augroup")

local LIST_ACTIVE_BUFFERS = {}
local BUFFER_NAME = "__coccon_buf__"
local BUFFER_ID = 0

---@class __cocoon_buf_opts
---@field limit integer

---@class __cocoon_buf
---@field name string
---@field bufnr integer
local M = {}

M.opts = {
    limit = 9,
}

---@param opts? __cocoon_buf_opts
function M.setup(opts)
    if opts then
        M.opts = utils.merge_tables(M.opts, opts)
    end
    return M
end

---@return integer | nil
function M.create()
    if not string.find(vim.api.nvim_buf_get_name(0), BUFFER_NAME) then
        if (BUFFER_ID + 1) <= M.opts.limit then
            BUFFER_ID = BUFFER_ID + 1
            M.bufnr = vim.api.nvim_create_buf(true, true) -- For debug reasons

            M:_set_buf_name()
            M:_register_buf_keymaps()
            M:_register_buf_autocmds()

            table.insert(LIST_ACTIVE_BUFFERS, M.bufnr)

            return M.bufnr
        end
    end
end

function M:_set_buf_name()
    M.name = BUFFER_NAME .. BUFFER_ID
    vim.api.nvim_buf_set_name(M.bufnr, M.name)
end

---@return boolean
---@param bufnr integer
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

---@return integer
function M.buf_list_length()
    local count = 0
    for _ in pairs(LIST_ACTIVE_BUFFERS) do
        count = count + 1
    end
    return count
end

---@return integer | nil
function M.get_first_buf()
    if M.buf_list_length() > 0 then
        return LIST_ACTIVE_BUFFERS[0]
    end
end

---@return nil
function M:_register_buf_keymaps()
    local opts = { buffer = M.bufnr, silent = true, noremap = true }
    vim.keymap.set("n", "q", function()
        vim.api.nvim_buf_delete(M.bufnr, { force = true, unload = true })
    end, opts)

    vim.keymap.set("n", "<C-k>", function()
        vim.api.nvim_buf_delete(M.bufnr, { force = true })
    end, opts)
end

function M._register_buf_autocmds()
    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        pattern = BUFFER_NAME .. "*",
        once = true,
        callback = function()
            pcall(
                vim.api.nvim_buf_delete,
                M.bufnr,
                { force = true, unload = true }
            )
        end,
    })
end

return M
