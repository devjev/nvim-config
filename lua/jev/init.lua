require('jev.lazy')

-- Enforce English
vim.cmd('language en_US')

-- Default colorscheme
vim.cmd([[colorscheme rose-pine]])

-- Basics
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.o.wrap = false
vim.opt.scrolloff = 8
vim.cmd([[set relativenumber]])

-- For a few particular file types, I want to have hard wrapping
vim.api.nvim_create_autocmd('FileType', {
	pattern = {'markdown', 'text'},
	callback = function()
		vim.bo.textwidth = 80
		vim.opt.colorcolumn = '80'
	end
})

-- Treat PostCSS files like CSS files
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
	pattern = {'*.pcss'},
	command = 'setfiletype css'
})

-- LSP 
require('jev.lsp')

-- Some keymaps (for the rest, see lsp.lua)
vim.g.mapleader = ' '
local builtin = require('telescope.builtin')

-- Tab-based keys
vim.keymap.set('n', '<Tab>', builtin.buffers, { noremap = True, silent = true })
vim.keymap.set('n', '<S-Tab>', 
	function() 
		vim.cmd([[Neotree toggle]]) 
	end, {noremap = true, silent = true}
)
vim.keymap.set('n', '<leader>fd', 
	function() 
		vim.cmd([[Telescope lsp_document_symbols]]) 
	end, {noremap = true, silent = true}
)

-- Finding stuff
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>gd', 
	function()
		vim.cmd([[Lspsaga peek_definition]])
	end, 
	{}
)
vim.keymap.set('n', '<leader>gh', 
	function()
		vim.cmd([[Lspsaga hover_doc]])
	end, 
	{}
)

-- Quick save
vim.keymap.set('n', '<esc><esc>', 
	function()
		vim.cmd([[wa]])
	end, 
	{}
)

-- Renaming stuff
vim.keymap.set('n', '<leader>qq', function() 
	return ':IncRename ' .. vim.fn.expand('<cword><CR>') 
end, {expr = true}) 

-- Chatting with Chad Gippity
vim.keymap.set('n', '<leader>cc', 
	function()
		vim.cmd([[GpChatToggle popup]])
	end, 
	{noremap = true, silent= true}
)


-- Own commands

--> Switch to certain colorschemes
local function LightsOn()
	vim.cmd([[colorscheme paper]])
	require('lualine').setup({ 
		options = {
			theme = 'auto'
		}
	})
end

local function LightsOff()
	vim.cmd([[colorscheme rose-pine]])
	vim.cmd([[set background=dark]])
	require('lualine').setup({
		options = {
			theme = 'palenight'
		}
	})
end

vim.api.nvim_create_user_command('LightsOn', LightsOn, {})
vim.api.nvim_create_user_command('LightsOff', LightsOff, {})
