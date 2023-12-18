local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local is_windows = vim.loop.os_uname().sysname == 'Windows_NT'

require('lazy').setup({
	-- Icons
	{'nvim-tree/nvim-web-devicons'},

	-- Telescope
	{ 
		'nvim-telescope/telescope.nvim', 
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},

	-- Dadbod ...
	{'tpope/vim-dadbod'},
	{'kristijanhusak/vim-dadbod-ui'},

	-- Zig
	{ 'ziglang/zig.vim' },

	-- Tree sitter
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		cond = function() return not is_windows end,
		config = function()
			local configs = require('nvim-treesitter.configs')
			configs.setup({
				ensure_installed = { 
					'lua', 
					'javascript', 
					'c', 
					'rust', 
					'html', 
					'elixir', 
					'erlang',
					'python',
					'typescript',
					'ocaml',
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end
	},

	-- Colorschemes
	{'neanias/everforest-nvim'},
	{'embark-theme/vim'},
	{'rose-pine/neovim'},
	{'relastle/bluewery.vim'},

	-- LSP
	{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
	{'neovim/nvim-lspconfig'},
	{'hrsh7th/cmp-nvim-lsp'},
	{'hrsh7th/nvim-cmp'},
	{'hrsh7th/cmp-buffer'},
	{'hrsh7th/cmp-path'},
	{'hrsh7th/cmp-cmdline'},
	{'L3MON4D3/LuaSnip'},

	-- Tree view
	{
		'nvim-neo-tree/neo-tree.nvim',
		branch = 'v3.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'MunifTanjim/nui.nvim'
		},
	},

	-- Bottom bar
	{
		'SmiteshP/nvim-navic',
		dependencies = { 'neovim/nvim-lspconfig' },
	},

	-- Renaming
	{
		'smjonas/inc-rename.nvim',
		config = function()
			require('inc_rename').setup()
		end
	}
})
