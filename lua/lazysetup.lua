-- Ensure Lazy is installed
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

require("lazy").setup({
	-- !COLOR SCHEMES
	{ "jaredgorski/fogbell.vim" },

	-- !SYSTEM THEME DETECTION
	{
		"f-person/auto-dark-mode.nvim",
		opts = {
			update_interval = 1000,
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd("colorscheme " .. vim.g.dark_colorscheme)
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd("colorscheme " .. vim.g.light_colorscheme)
			end,
		},
	},

	-- !ICONS
	{ "nvim-tree/nvim-web-devicons" },

	-- !ZEN MODE
	{ "folke/zen-mode.nvim" },

	-- !TABS
	{
		"nanozuki/tabby.nvim",
		opts = {
			line = function(line)
				local theme = {
					fill = "TabLineFill",
					head = "TabLine",
					current_tab = "TabLineSel",
					tab = "TabLine",
					win = "TabLine",
					tail = "TabLine",
				}
				local sep_right = " "
				local sep_left = " "
				-- local sep_right = ''
				-- local sep_left  = ''
				-- if vim.g.is_windows then
				--     sep_right = ' '
				--     sep_left =  ' '
				-- end
				return {
					{
						{ "  ", hl = theme.head },
						line.sep(sep_right, theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep(sep_left, hl, theme.fill),
							tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep(sep_right, hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
						return {
							line.sep(sep_left, theme.win, theme.fill),
							win.is_current() and "" or "",
							win.buf_name(),
							line.sep(sep_right, theme.win, theme.fill),
							hl = theme.win,
							margin = " ",
						}
					end),
					{
						line.sep(sep_left, theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end,
		},
	},

    -- !FOLDING
    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require('ufo').setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return {'lsp', 'indent'}
                end
            })
        end
    },

	-- !TELESCOPE
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({})
		end,
	},

	-- !LUALINE
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					-- Remove decorations, because we are not 14
					-- component_separators = { left = '', right = ''},
					-- section_separators = { left = '', right = ''},
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = {},
						winbar = {},
					},
					ignore_focus = {},
					always_divide_middle = true,
					always_show_tabline = true,
					globalstatus = false,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
						refresh_time = 16, -- ~60fps
						events = {
							"WinEnter",
							"BufEnter",
							"BufWritePost",
							"SessionLoadPost",
							"FileChangedShellPost",
							"VimResized",
							"Filetype",
							"CursorMoved",
							"CursorMovedI",
							"ModeChanged",
						},
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					-- lualine_x = {'encoding', 'fileformat', 'filetype'},
					lualine_x = { "encoding", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				winbar = {},
				inactive_winbar = {},
				extensions = {},
			})
		end,
	},

	-- Comment.nvim
	{
		"numToStr/Comment.nvim",
		opts = {},
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},

	-- !TYPST
	{
		"sylvanfranklin/omni-preview.nvim",
		dependencies = {
			{ "chomosuke/typst-preview.nvim", lazy = true },
			{ "hat0uma/csvview.nvim", lazy = true },
		},
		opts = {},
	},

	-- !Colors
	-- {
	--     "brenoprata10/nvim-highlight-colors",
	--     config = function()
	--         require("nvim-highlight-colors").setup({
	--             render = "background", -- or 'virtual', 'foreground'
	--             enable_tailwind = true,
	--         })
	--     end,
	-- },
	{
		"uga-rosa/ccc.nvim",
		event = "VeryLazy",
		config = function()
			local ccc = require("ccc")

			ccc.setup({
				-- 1. Enable the highlighter (highlighting hex codes in text)
				highlighter = {
					auto_enable = true, -- Crucial: defaults to false in some versions
					lsp = true, -- Use LSP to identify color names if available
				},

				-- 2. Customize the picker (optional tweaks)
				default_point = { "100%", "50%" }, -- Start picker at full saturation/brightness
			})

			--   -- 3. Set a keybind to open the picker
			--   -- This opens the UI to modify the color under your cursor or insert a new one
			--   vim.keymap.set("n", "<leader>cp", ":CccPick<CR>", { desc = "Pick Color" })
		end,
	},

	-- !DEBUGGER
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
		},
		config = function()
			-- local dap = require "dap"
			local ui = require("dapui")
			local vt = require("nvim-dap-virtual-text")
			ui.setup()
			vt.setup()
		end,
	},

	{
		"mfussenegger/nvim-dap-python",
		config = function()
			-- Assume a global installation
			require("dap-python").setup("python")
		end,
	},

	{
		"julianolf/nvim-dap-lldb",
		dependencies = { "mfussenegger/nvim-dap" },
		-- Assume codelldb is in path
		opts = { codelldb_path = "codelldb" },
	},

	-- !TREE SITTER
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		cond = function()
			return not vim.g.is_windows
		end,
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = {
					"lua",
					"javascript",
					"typescript",
					"c",
					"rust",
					"html",
					"css",
					"python",
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
		end,
	},

	-- !LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Left blank on purpose - apparently lazy.nvim is trying
			-- to automatically load up plugins with setup, which conflicts
			-- with my neovim version-dependent approach.
		end,
	},
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },

	-- !LANGUAGE SUPPORT
	-- Rust
	{
		"rust-lang/rust.vim",
		ft = "rust",
		init = function()
			vim.g.rustfmt_autosave = 1
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		lazy = false,
		["rust-analyzer"] = {
			cargo = { allFeatures = true },
		},
	},

	-- Zig
	{ "ziglang/zig.vim" },

	-- Jinja / Nunjucks
	{ "lepture/vim-jinja" },

	-- Yuck (LISP variant used by eww widget program)
	{ "elkowar/yuck.vim" },

	-- Lua support
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- Clingo syntax support
	{ "rkaminsk/vim-syntax-clingo" },

	-- !REPL
	{
		"Vigemus/iron.nvim",
		event = "VeryLazy",
		opts = function()
			local view = require("iron.view")

			return {
				config = {
					scratch_repl = true,
					repl_open_cmd = view.split.vertical.botright(40),
					repl_filetype = function(bufnr, ft)
						return ft
					end,
					repl_definition = {
						python = {
							command = function()
								if vim.g.is_windows then
									return { "python", "-m", "IPython", "--no-autoindent" }
								else
									return { "uv", "run", "ipython", "--no-autoindent" }
								end
							end,
						},
						["*"] = {
							command = function()
								if vim.g.is_windows then
									return { "powershell.exe", "-NoProfile" }
								else
									return { "zsh" }
								end
							end,
						},
					},
				},
			}
		end,
	},

	-- !FILE MANAGER
	{
		"stevearc/oil.nvim",
		---@module "oil"
		---@type oil.SetupOpts
		opts = {},
		-- Optional dependencies
		-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
		dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
		config = function()
			require("oil").setup({
				default_file_explorer = true,
			})
		end,
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

	-- !GIT
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			if vim.g.is_windows then
				require("gitsigns").setup({
					-- ??? Signs do seem to work on Windows...
					-- signs = {
					--     add          = { text = "+" },
					--     change       = { text = "~" },
					--     delete       = { text = "-" },
					--     topdelete    = { text = "-" },
					--     changedelete = { text = "~" },
					--     untracked    = { text = "?" },
					-- }
				})
			else
				require("gitsigns").setup({})
			end
		end,
	},
	{ "tpope/vim-fugitive" },
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
		config = function()
			require("neogit").setup({})
		end,
	},

	-- !Writing / Zen mode
	{ "pocco81/true-zen.nvim" },

	-- ! NOTE TAKING
	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		ft = "markdown",

		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},

		cmd = {
            "ObsidianDailies",
			"ObsidianSearch",
			"ObsidianNew",
			"ObsidianQuickSwitch",
			"ObsidianBacklinks",
			"ObsidianTags",
		},

		config = function()
			if vim.g.is_windows then
				local home = vim.fn.expand("$USERPROFILE")
				vim.g.notes_root = home .. "\\Documents\\Notes"
			else
				local home = vim.fn.expand("~")
				vim.g.notes_root = home .. "/Notes"
			end

			require("obsidian").setup({
				workspaces = {
					{
						name = "main",
						path = vim.fn.expand(vim.g.notes_root .. "/main"),
					},
				},

                completion = {
                    nvim_cmp = true,
                    min_chars = 2,
                }
			})
		end,
	},
})
