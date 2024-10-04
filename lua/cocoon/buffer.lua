local utils = require("cocoon.utils")
local augroup = require("cocoon.augroup")

local LIST_ACTIVE_BUFFERS = {}
local BUFFER_NAME = "__coccon_buf__"
local BUFFER_ID = 0

---@class __cocoon_buf_opts
---@field limit integer

---@class __cocoon_buf
---@field opts __cocoon_buf_opts
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
            local bufnr = vim.api.nvim_create_buf(true, true) -- For debug reasons

            M:_set_buf_name(bufnr)
            M:_register_buf_keymaps(bufnr)
            M:_register_buf_autocmds()

            table.insert(LIST_ACTIVE_BUFFERS, bufnr)

            return bufnr
        end
    end
end

---@param bufnr integer
function M:_set_buf_name(bufnr)
    local name = BUFFER_NAME .. BUFFER_ID
    vim.api.nvim_buf_set_name(bufnr, name)
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
        return LIST_ACTIVE_BUFFERS[1]
    end
end

---@return nil
function M:_remove_buf_from_list(bufnr)
    if not bufnr then return nil end
    for i, v in ipairs(LIST_ACTIVE_BUFFERS) do
        if v == bufnr then
            table.remove(LIST_ACTIVE_BUFFERS, i)
        end
    end
end

---@return nil
---@param bufnr integer
function M:_register_buf_keymaps(bufnr)
    local opts = { buffer = bufnr, silent = true, noremap = true }
    vim.keymap.set("n", "q", function()
        vim.api.nvim_buf_delete(bufnr, { force = true, unload = true })
    end, opts)

    vim.keymap.set("n", "<C-k>", function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
        M:_remove_buf_from_list(bufnr)
    end, opts)
end

---@return nil
function M:_register_buf_autocmds()
    local cocoon_pattern = BUFFER_NAME .. "*"
    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        pattern = cocoon_pattern,
        callback = function()
            pcall(
                vim.api.nvim_buf_delete,
                vim.api.nvim_win_get_buf(0),
                { force = true, unload = true }
            )
        end,
    })
end

return M
