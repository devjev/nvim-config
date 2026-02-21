-- Environment setup
--
-- Identify if we are on a Windows machine, since then some things
-- will not work. For example treesitter needs a C/C++ compiler to install.
vim.g.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- Neovim setup
require("lazysetup")
require("lspsetup")
require("keybindings")

-- Enforce English
vim.cmd("language en_US.UTF-8")

-- Colorschemes
vim.g.dark_colorscheme = "Tomorrow-Night-Blue"
vim.g.light_colorscheme = "lunaperche"
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

-- Make sure that code is folded only when explicitly requested
-- Set up in such a way to work well with UFO
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
-- shamelessly vibecoded
vim.o.statuscolumn = '%=%s%#FoldColumn#%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? " " : " ") : "  " }'
vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep:│,foldclose:'

-- Set default terminal to PowerShell 5, if on windows
if vim.g.windows then
	vim.opt.shell = "powershell.exe"
end

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.bo.textwidth = 76
        vim.opt_local.conceallevel = 2
	end,
})

-- For emails, though - I want soft wrapping
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "mail" },
	callback = function()
        vim.opt_local.textwidth = 0
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.conceallevel = 0
	end,
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

-- Windows specific setting, making sure PowerShell plays nice with Neovim
if vim.g.is_windows then
	vim.opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
	vim.opt.shellcmdflag =
		"-NoLogo -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
	vim.opt.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
	vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
	vim.opt.shellquote = ""
	vim.opt.shellxquote = ""
end

-- GUI / Neovide Configuration
if vim.g.neovide then
	-- Set the font and size (Syntax: Font Name:hSize)
	-- Replace 'JetBrainsMono Nerd Font' with your preferred font
	vim.o.guifont = "JetBrainsMono Nerd Font:h12"
	-- Optional: Scale the entire UI (useful for high-DPI screens)
	vim.g.neovide_scale_factor = 1.0
	-- Optional: Adjust line spacing
	-- vim.g.neovide_linespace = 0
end
