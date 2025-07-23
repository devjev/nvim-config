require("lazysetup")
require("lspsetup")
require("keybindings")

-- Enforce English
vim.cmd("language en_US.UTF-8")

-- Default colorscheme
vim.cmd([[colorscheme lackluster-dark]])

local function set_transparent_bg()
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
end

-- Create an autocommand group to prevent stacking duplicates
local transparent_augroup = vim.api.nvim_create_augroup('TransparentBG', { clear = true })

-- Create the autocommand
vim.api.nvim_create_autocmd(
  -- A list of events to listen for
  { 'ColorScheme', 'OptionSet' },
  {
    -- The pattern to match for each event
    pattern = { '*', 'background' },
    -- The function to call when the event fires
    callback = set_transparent_bg,
    -- The autocommand group to belong to
    group = transparent_augroup,
  }
)

-- Optional: Run it once on startup as well
set_transparent_bg()

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.o.wrap = false
vim.opt.scrolloff = 8

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd("FileType", {
	pattern = {"markdown", "text"},
	callback = function()
		vim.bo.textwidth = 80
		vim.opt.colorcolumn = "80"
	end
})
