require("lazysetup")
require("lspsetup")
require("keybindings")

-- Enforce English
vim.cmd("language en_US.UTF-8")

-- Default colorscheme = oxocarbon, but tweaked 
-- to have lualine darker
vim.cmd([[colorscheme carbonfox]])

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.o.wrap = false
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showtabline = 1

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd("FileType", {
	pattern = {"markdown", "text"},
	callback = function()
		vim.bo.textwidth = 80
		vim.opt.colorcolumn = "80"
	end
})

-- Sign column
vim.opt.signcolumn = "yes"
-- See this: https://github.com/AnirudhG07/dotfiles/blob/6d75616e1f059753fe27f8377a82560c6476b725/nvim/.config/nvim/lua/anirudh/plugins/lsp/lspconfig.lua#L79
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.diagnostic.config({
        signs = {
            text = icon,
            linehl = hl,
            numhl = "",
        },
    })
end
