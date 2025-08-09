require("lazysetup")
require("lspsetup")
require("keybindings")

-- Enforce English
vim.cmd("language en_US.UTF-8")

-- Colorschemes
vim.g.dark_colorscheme  = "carbonfox"
vim.g.light_colorscheme = "modus_operandi"
vim.cmd("colorscheme " .. vim.g.dark_colorscheme)

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.wrap = false
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
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "󰠠 ",
            [vim.diagnostic.severity.INFO] = " ",
        },
        linehl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
        },
        numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
    },
})
