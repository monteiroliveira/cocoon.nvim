local utils = require("cocoon.utils")

local M = {}

function M:create_term_proc(cmd)
    if cmd ~= nil then
        vim.fn.termopen(cmd)
    else
        vim.fn.termopen(vim.o.shell)
    end
    vim.api.nvim_command("startinsert")
end

function M.create_term_session(bufnr, cmd)
    vim.api.nvim_buf_call(bufnr, function()
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        M:create_term_proc(cmd)
        vim.api.nvim_buf_set_name(bufnr, bufname) -- Dummy
    end)
end

return M
