local api = vim.api
local o = vim.o

local CocoonGroup = require("cocoon.augroup")

CocoonConfig = {
    width = 120,
    height = 30,
    border = "rounded",
}

---@class Cocoon
---@field config table
local Cocoon = {}

---@return Cocoon
function Cocoon:new()
    self.__index = self
    local cocoon = setmetatable({
        config = CocoonConfig,
    }, self)
    return cocoon
end

---@return number
function Cocoon:create_buf()
    local buf = api.nvim_create_buf(false, true)
    return buf
end

---@return number
---@param buf number
function Cocoon:open_window(buf)
    local win = api.nvim_open_win(buf, true, {
        title = "Cocoon",
        title_pos = "center",
        relative = "win",
        width = self.config.width,
        height = self.config.height,
        row = math.floor((o.lines - self.config.height) / 2),
        col = math.floor((o.columns - self.config.width) / 2),
        style = "minimal",
        border = "single",
    })
    return win
end

---@return nil
---@param script string
function Cocoon:call_terminal_win(script)
    local buf = self:create_buf()
    local win = self:open_window(buf)
    api.nvim_create_autocmd("TermOpen", {
        group = CocoonGroup,
        buffer = buf,
        once = true,
        callback = function()
            vim.cmd.startinsert()
        end,
    })
    api.nvim_create_autocmd("TermClose", {
        group = CocoonGroup,
        buffer = buf,
        once = true,
        callback = function()
            api.nvim_win_close(win, true)
        end,
    })
    vim.fn.termopen(script, { pty = win })
end

local cocoon = Cocoon:new()

---@param self Cocoon
---@param config table
---@return Cocoon
function Cocoon.setup(self, config) -- I don't know whats happening
    if self ~= cocoon then
        config = self
        self = cocoon
    end

    for _, v in pairs(config) do
        table.insert(self.config, v)
    end

    return self
end

return cocoon
