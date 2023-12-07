require('jev.lazy')

-- Default colorscheme
vim.cmd([[colorscheme everforest]])

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.wo.wrap = false

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd('FileType', {
	pattern = {'markdown', 'text'},
	callback = function()
		vim.bo.textwidth = 80
	end
})

-- Some keymaps (for the rest, see lsp.lua)
vim.g.mapleader = ' '
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>bb', vim.cmd('Neotree'), {})

-- LSP 
require('jev.lsp')
