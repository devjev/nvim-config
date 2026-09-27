-- Version floor. Everything below assumes Neovim 0.11.3 or newer: vim.lsp.config
-- and vim.lsp.enable, vim.uv, the diagnostic sign tables, and the plugin
-- versions pinned in lazysetup.lua. Ubuntu 26.04 ships 0.11.6; Debian 13 and
-- Ubuntu 24.04 need a release tarball in ~/.local/bin. Stop here with one
-- message instead of failing piecemeal further down.
if vim.fn.has("nvim-0.11.3") == 0 then
	local v = vim.version()
	vim.api.nvim_echo({
		{
			string.format(
				"This configuration needs Neovim 0.11.3 or newer; this is %d.%d.%d. Nothing was loaded.",
				v.major,
				v.minor,
				v.patch
			),
			"ErrorMsg",
		},
	}, true, {})
	return
end

-- Environment setup
--
-- Identify if we are on a Windows machine, since then some things
-- will not work. For example treesitter needs a C/C++ compiler to install.
vim.g.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

-- Leader key. lazy.nvim creates the key triggers from its `keys` specs during
-- setup, so this must be set before lazysetup runs or those triggers expand
-- <leader> to the default backslash.
vim.g.mapleader = " "

-- Neovim setup
require("lazysetup")
require("lspsetup")
require("keybindings")

-- Enforce English. A machine without that locale generated (a minimal Debian
-- or Ubuntu often has only C.UTF-8) raises E197 here; that must not abort the
-- rest of this file, so catch it and say so once the UI is up.
local lang_ok, lang_err = pcall(vim.cmd.language, "en_US.UTF-8")
if not lang_ok then
	vim.schedule(function()
		vim.notify(
			"Could not set the message language to en_US.UTF-8, using the system default.\n"
				.. tostring(lang_err):gsub("^.-E197", "E197")
				.. "\nDebian/Ubuntu: sudo locale-gen en_US.UTF-8",
			vim.log.levels.WARN
		)
	end)
end

-- Colorschemes
vim.g.dark_colorscheme = "Tomorrow-Night-Blue"
vim.g.light_colorscheme = "lunaperche"
vim.opt.termguicolors = false
vim.cmd("colorscheme default")

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.showtabline = 1

-- Folds come from the syntax tree (treesitter foldexpr); lspsetup.lua switches
-- a window to the LSP foldexpr when the server provides folding ranges. Nothing
-- is folded until asked for (foldlevel 99).
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

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
