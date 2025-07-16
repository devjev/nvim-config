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

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

require("lazy").setup({

	-- Colorschemes
	{"yorickpeterse/vim-paper"},
	{"craftzdog/solarized-osaka.nvim"},
	{"miikanissi/modus-themes.nvim"},
	{"rose-pine/neovim", name = "rose-pine"},
    {
        "anAcc22/sakura.nvim",
        dependencies = { "rktjmp/lush.nvim" }
    },
    {"slugbyte/lackluster.nvim"},

	-- Icons
	{"nvim-tree/nvim-web-devicons"},

	-- Telescope
	{ 
		"nvim-telescope/telescope.nvim", 
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" }
	},

	-- Lualine
	{
    	"nvim-lualine/lualine.nvim",
	    dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({})
		end
	},

	-- Comment.nvim
	{ 
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
		config = function()
		    require("Comment").setup()
		end
	},
	
	-- ChatGPT integration
	{
		"robitx/gp.nvim",
		config = function()
			-- We need CURL for this to function, so should initalize only if
			-- curl is installed on the system.
			-- NOTE: Turn off support for Windows temporarily
			if vim.fn.executable("curl") == 1 and not is_windows then
				require("gp").setup({
					style_popup_border = "rounded",
					style_popup_max_width = 90,
				})
			end
		end,
	},

	-- Dadbod (NOTE can"t get it to work with ODBC on windows)
	--{"tpope/vim-dadbod"},
	--{"kristijanhusak/vim-dadbod-ui"},

	-- Tree sitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		cond = function() return not is_windows end,
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = { 
					"lua", 
					"javascript", 
					"c", 
					"rust", 
					"html", 
					"css",
					"elixir", 
					"erlang",
					"python",
					"typescript",
					"ocaml",
					"go",
					"proto",
					"terraform",
					"hcl",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end
	},

	-- LSP
	-- {"VonHeikemen/lsp-zero.nvim", branch = "v3.x"},
	{"neovim/nvim-lspconfig"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"hrsh7th/cmp-cmdline"},
	{"L3MON4D3/LuaSnip"},

	-- Rust
	{ "rust-lang/rust.vim" },

	-- Zig
	{ "ziglang/zig.vim" },

	-- Jinja / Nunjucks
	{ "lepture/vim-jinja" },

	-- Svelte
	{ "othree/html5.vim" },
	{ "pangloss/vim-javascript" },
	{ "evanleck/vim-svelte", branch = "main" },

	-- Tree view
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim"
		},
	},

	-- Renaming
	{
		"smjonas/inc-rename.nvim",
		config = function()
			require("inc_rename").setup()
		end
	}
})
