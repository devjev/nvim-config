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
vim.fn.sign_define('DiagnosticSignError', { text = '❌', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '⚠️', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = '📘', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '💡', texthl = 'DiagnosticSignHint' })
