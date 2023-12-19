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
	--
	-- Colorschemes {'rose-pine/neovim'},
	{'yorickpeterse/vim-paper'},
	{'ok-ryoko/blue-screen'},
	{'https://gitlab.com/protesilaos/tempus-themes-vim.git'},
	{'craftzdog/solarized-osaka.nvim'},

	-- Icons
	{'nvim-tree/nvim-web-devicons'},

	-- Telescope
	{ 
		'nvim-telescope/telescope.nvim', 
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},

	-- Dadbod (NOTE can't get it to work with ODBC on windows)
	--{'tpope/vim-dadbod'},
	--{'kristijanhusak/vim-dadbod-ui'},

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
					'css',
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

	-- Renaming
	{
		'smjonas/inc-rename.nvim',
		config = function()
			require('inc_rename').setup()
		end
	},

	-- Git integration / tools
	{
		"chrisgrieser/nvim-tinygit",
		ft = { "gitrebase", "gitcommit" }, -- so ftplugins are loaded
		dependencies = {
			"stevearc/dressing.nvim",
			"rcarriga/nvim-notify", -- optional, but recommended
		},
	},
})
