# Ensure Lazy is installed
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

require("lazy").setup {
	-- Colorschemes
    {"slugbyte/lackluster.nvim"},

    {"andreasvc/vim-256noir"},

    {
        "xiyaowong/transparent.nvim",
        config = function()
            vim.cmd([[TransparentEnable]])            
        end
    },  -- make the background transparent

    -- Icons (TODO probably won"t work on my Windows setups)
	{"nvim-tree/nvim-web-devicons"},

	-- Telescope
	{ 
		"nvim-telescope/telescope.nvim", 
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
    
	-- Lualine (TODO need to customize this)
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

    -- Setup LSP
	{"neovim/nvim-lspconfig"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"hrsh7th/cmp-cmdline"},

    -- !LANGUAGE SUPPORT
	-- Rust
	{ "rust-lang/rust.vim" },

	-- Zig
	{ "ziglang/zig.vim" },

	-- Jinja / Nunjucks
	{ "lepture/vim-jinja" },


    -- !FILE MANAGER
    {
        "stevearc/oil.nvim",
        ---@module "oil"
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
        config = function()
            require("oil").setup {
                default_file_explorer = true,
            }
        end
    },

    -- Which Key - shortcut lookup
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      keys = {
        {
          "<leader>?",
          function()
            require("which-key").show({ global = false })
          end,
          desc = "Buffer Local Keymaps (which-key)",
        },
      },
    },

    -- !WIKI
    {
      "lervag/wiki.vim",
      -- tag = "v0.10", -- uncomment to pin to a specific release
      init = function()
            vim.g.wiki_root = "~/Wiki"
        -- wiki.vim configuration goes here, e.g.
      end
    },

    -- !MARKDOWN
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        opts = {
            heading = {
                background = {}
            }
        },
    }
}


