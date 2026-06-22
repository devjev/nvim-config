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

-- Graceful degradation on older Neovim. A handful of plugins below require a
-- newer Neovim than 0.9. Gate each with lazy.nvim's `cond` so the plugin stays
-- installed but never loads (no setup, no error) when the running Neovim is too
-- old. `min_nvim("0.10")` is true on 0.10+, false on 0.9. Plugins reached only
-- via an Ex command (Markview, OmniPreview) degrade to a missing command;
-- nothing `require`s the gated plugins at startup, so no keymap or module load
-- breaks on 0.9.
local function min_nvim(ver)
	return vim.fn.has("nvim-" .. ver) == 1
end

require("lazy").setup({
    -- !GITHUB COPILOT
    { "github/copilot.vim" },

	-- !COLOR SCHEMES
	{ "jaredgorski/fogbell.vim" },
    { "chriskempson/vim-tomorrow-theme" },
    { "nyoom-engineering/oxocarbon.nvim" },
    { "noahfrederick/vim-noctu" },  -- 16-color terminal theme

	-- !SYSTEM THEME DETECTION
    -- TODO Removed for now as I use a blue color scheme, which is comfortable
    --      for both dark and light environments, but necessary for white / black
    --      color schemes.
	-- {
	-- 	"f-person/auto-dark-mode.nvim",
	-- 	opts = {
	-- 		update_interval = 1000,
	-- 		set_dark_mode = function()
	-- 			vim.api.nvim_set_option_value("background", "dark", {})
	-- 			vim.cmd("colorscheme " .. vim.g.dark_colorscheme)
	-- 		end,
	-- 		set_light_mode = function()
	-- 			vim.api.nvim_set_option_value("background", "light", {})
	-- 			vim.cmd("colorscheme " .. vim.g.light_colorscheme)
	-- 		end,
	-- 	},
	-- },

	-- !ICONS
	{ "nvim-tree/nvim-web-devicons" },

	-- !ZEN MODE
	-- Super-minimal: a single centered column, everything else stripped —
	-- no numbers, signcolumn, cursorline, fold/statusline, or backdrop dim.
	{
		"folke/zen-mode.nvim",
		opts = {
			window = {
				backdrop = 1, -- 1.0 = no dimming of the surrounding area
				width = 80, -- centered fixed-width column
				height = 1, -- 1.0 = full height
				options = {
					number = false,
					relativenumber = false,
					signcolumn = "no",
					cursorline = false,
					cursorcolumn = false,
					foldcolumn = "0",
					list = false,
				},
			},
			plugins = {
				options = {
					enabled = true,
					ruler = false,
					showcmd = false,
					laststatus = 0, -- hide the statusline (lualine)
				},
				gitsigns = { enabled = false },
			},
		},
	},

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
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "BufReadPost", -- Load nicely after the file opens
        config = function()
            require("ufo").setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return { "lsp", "indent" }
                end,
            })
        end,
    },

	-- !TELESCOPE
	{
		"nvim-telescope/telescope.nvim",
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
	-- csvview requires Neovim 0.10; gate the whole preview stack off on 0.9.
	{
		"sylvanfranklin/omni-preview.nvim",
		cond = min_nvim("0.10"),
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
			-- mason 2.x requires Neovim 0.10; it's only a passive dep here (never
			-- configured), so gate it off on 0.9 to keep the dap stack loading.
			{ "williamboman/mason.nvim", cond = min_nvim("0.10") },
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
	-- nvim-treesitter split into two incompatible branches. The legacy "master"
	-- (configs.setup with highlight/indent modules) was archived and breaks on
	-- Neovim 0.12: directive handlers now receive arrays of nodes, so master's
	-- markdown injection predicate calls :range() on a table and errors out. The
	-- "main" rewrite requires 0.12+, drops the module system, and drives
	-- highlighting through core vim.treesitter.start(). Pick the branch by Neovim
	-- version so this config keeps working on machines with older Neovim too.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = vim.fn.has("nvim-0.12") == 1 and "main" or "master",
		lazy = false,
		build = ":TSUpdate",
		cond = function()
			return not vim.g.is_windows
		end,
		config = function()
			local languages = {
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
				"markdown",
				"markdown_inline",
			}
			if vim.fn.has("nvim-0.12") == 1 then
				-- main branch: compile only the parsers we don't already have, so
				-- startup doesn't kick off an install pass every launch. Building
				-- needs the tree-sitter CLI + a C compiler on PATH (provided by the
				-- NixOS config). Then start core treesitter per buffer (the
				-- highlight/indent modules no longer exist).
				local installed = require("nvim-treesitter.config").get_installed("parsers")
				local missing = vim.tbl_filter(function(lang)
					return not vim.tbl_contains(installed, lang)
				end, languages)
				if #missing > 0 then
					require("nvim-treesitter").install(missing)
				end
				vim.api.nvim_create_autocmd("FileType", {
					callback = function(args)
						local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
						if lang and pcall(vim.treesitter.start, args.buf, lang) then
							vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						end
					end,
				})
			else
				-- legacy master branch (Neovim < 0.12)
				require("nvim-treesitter.configs").setup({
					ensure_installed = languages,
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end
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
	-- rustaceanvim ^6 requires Neovim 0.11; off on older Neovim. rust.vim
	-- (above) still provides syntax + rustfmt-on-save when this is gated out.
	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		cond = min_nvim("0.11"),
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
		cond = min_nvim("0.10"), -- requires Neovim 0.10; lua_ls still works without it
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

	-- Alloy syntax support (.als). The .als -> alloy filetype is already
	-- registered in lspsetup.lua; this adds Alloy 6 regex highlighting
	-- (sig/pred/fun/fact, quantifiers, temporal operators). The alloy LSP
	-- handles semantics; this gives static coloring without a treesitter
	-- parser (Alloy isn't in the nvim-treesitter registry).
	{ "runoshun/vim-alloy", ft = "alloy" },

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
	-- Git diff view (<leader>vc). Standalone since dropping Neogit (lazygit is
	-- used outside nvim instead); diffview only needs Neovim 0.7.
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Prose wrapping: vim-pencil manages formatoptions so hard-wrapped prose
	-- (textwidth=76, set per-filetype in init.lua) reflows cleanly on edit and
	-- `gq`, while navigation still moves by display lines. Scoped to prose
	-- filetypes; `mail` keeps its own soft-wrap handling from init.lua.
	{
		"preservim/vim-pencil",
		ft = { "markdown", "text" },
		init = function()
			vim.g["pencil#wrapModeDefault"] = "hard"
			vim.g["pencil#textwidth"] = 76
			vim.g["pencil#concealcursor"] = "c"
		end,
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "text" },
				callback = function()
					vim.fn["pencil#init"]()
				end,
			})
		end,
	},

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
                },
                note_id_func = function(title)
                    -- 1. Create the base slug from the title
                    local name = ""
                    if title ~= nil then
                        name = title:gsub(" ", "-"):gsub("[^%w%s-]", ""):lower()
                    else
                        -- Fallback for empty titles
                        name = "untitled-" .. tostring(os.time())
                    end

                    -- 2. Construct the potential full path to check for existence
                    -- We use the notes_root and workspace path defined in your config
                    local path = vim.fn.expand(vim.g.notes_root .. "/main/" .. name .. ".md")

                    -- 3. Check if the file exists
                    if vim.loop.fs_stat(path) then
                        -- If it exists, prefix with ISO datetime (YYYY-MM-DD-HHMM)
                        return tostring(os.date("%Y-%m-%d-%H%M")) .. "-" .. name
                    else
                        -- Otherwise, return just the slugged title
                        return name
                    end
                end,
			})
		end,
	},

	-- ! MARKDOWN RENDERING
	-- In-buffer rendering of headings, lists, tables, callouts, code blocks,
	-- LaTeX and inline HTML as you edit (no browser). Relies on the markdown /
	-- markdown_inline / html treesitter parsers already installed above, and
	-- the conceallevel=2 set for markdown in init.lua. Toggle with :Markview
	-- (bound to <leader>pm).
	{
		"OXY2DEV/markview.nvim",
		cond = min_nvim("0.10.3"), -- requires Neovim 0.10.3; off on 0.9 (raw markdown source)
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- Render tables only — everything else (headings, lists, code
			-- blocks, quotes, links, emphasis, LaTeX, HTML, frontmatter) stays
			-- as plain markdown source with no concealing, so nothing reflows.
			-- NB: leave `tables` unspecified. markview's config merge treats a
			-- user-provided sub-table as a replacement, so `tables = { enable =
			-- true }` would wipe the default `parts` (border glyphs) and the
			-- table would render with no borders. Tables are enabled by default.
			require("markview").setup({
				markdown = {
					enable = true,
					headings = { enable = false },
					list_items = { enable = false },
					code_blocks = { enable = false },
					block_quotes = { enable = false },
					horizontal_rules = { enable = false },
					metadata_minus = { enable = false },
					metadata_plus = { enable = false },
					reference_definitions = { enable = false },
				},
				markdown_inline = { enable = false },
				latex = { enable = false },
				html = { enable = false },
				yaml = { enable = false },
				typst = { enable = false },
			})
		end,
	},

	-- ! MARKDOWN TABLES
	-- Auto-align Markdown tables as you type; colons in the separator row
	-- drive per-column alignment. Toggle the auto behaviour with :Mtm.
	{
		"Kicamon/markdown-table-mode.nvim",
		ft = "markdown",
		config = function()
			require("markdown-table-mode").setup()
		end,
	},

})
