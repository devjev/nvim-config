require('jev.lazy')

-- Enforce English
vim.cmd('language en_US')

-- Default colorscheme
vim.cmd([[colorscheme rose-pine]])

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.wo.wrap = false
vim.opt.scrolloff = 999

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd('FileType', {
	pattern = {'markdown', 'text'},
	callback = function()
		vim.bo.textwidth = 80
	end
})

-- LSP 
require('jev.lsp')

-- Some keymaps (for the rest, see lsp.lua)
vim.g.mapleader = ' '
local builtin = require('telescope.builtin')

-- Tab-based keys
vim.keymap.set('n', '<Tab>', builtin.buffers, { noremap = True, silent = true })
vim.keymap.set('n', '<S-Tab>', function() vim.cmd([[Neotree toggle]]) end, {noremap = true, silent = true})
vim.keymap.set('n', '<A-Tab>', function() vim.cmd([[Telescope lsp_document_symbols]]) end, {noremap = true, silent = true})

-- Finding stuff
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>rn', function() return ':IncRename' .. vim.fn.expand('<cword>') end, {expr = true}) 
