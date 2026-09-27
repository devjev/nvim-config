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

-- Tooling on non-NixOS machines. The NixOS configs put the tree-sitter CLI and a
-- C compiler on PATH for us; a Debian or Ubuntu machine has them only after
-- `apt install build-essential tree-sitter-cli`, and hand-installed binaries land
-- in ~/.local/bin, which a desktop-launched Neovim does not always inherit.
-- Prepend it, then probe once. Both nvim-treesitter branches need a C compiler to
-- build parsers (main runs `tree-sitter build`, which calls the compiler; master
-- calls it directly), so the probes gate the build step and the install pass
-- below. A machine without the toolchain degrades to the parsers it already has,
-- plus one warning, instead of an error out of vim.system on every launch.
if not vim.g.is_windows then
	local local_bin = vim.fn.expand("~/.local/bin")
	if vim.fn.isdirectory(local_bin) == 1 and not string.find(vim.env.PATH or "", local_bin, 1, true) then
		vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
	end
end
local has_ts_cli = vim.fn.executable("tree-sitter") == 1
-- Same candidates and order as nvim-treesitter's own compiler lookup.
local has_cc = false
for _, cc in ipairs({ vim.env.CC, "cc", "gcc", "clang", "zig" }) do
	if cc and cc ~= "" and vim.fn.executable(cc) == 1 then
		has_cc = true
		break
	end
end

-- Startup warnings. A vim.notify issued while plugins load is drawn before the
-- first redraw and can be wiped by it, so collect the messages and show them
-- once the UI is up. A multi-line WARN goes through the hit-enter prompt, so it
-- cannot be missed, and it stays in :messages.
local startup_warnings = {}
local function warn_at_startup(msg)
	table.insert(startup_warnings, msg)
end
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		if #startup_warnings == 0 then
			return
		end
		vim.schedule(function()
			vim.notify(table.concat(startup_warnings, "\n\n"), vim.log.levels.WARN)
		end)
	end,
})

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
    { "noahfrederick/vim-noctu" },  -- 16-color terminal theme

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
        opts = {
            provider_selector = function()
                return { "lsp", "indent" }
            end,
        },
    },

	-- !TELESCOPE
	{
		"nvim-telescope/telescope.nvim",
		-- telescope's master/0.2.x line hard-errors ("requires at least
		-- nvim-0.11"); the 0.1.x branch supports Neovim 0.7+. Track 0.1.x below
		-- 0.11 so it loads on 0.9.5; latest on 0.11+.
		branch = vim.fn.has("nvim-0.11") == 0 and "0.1.x" or nil,
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- !LUALINE
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				-- Remove decorations, because we are not 14
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	-- Comment.nvim, only below Neovim 0.10, which has the same gc / gcc
	-- operator built in.
	{
		"numToStr/Comment.nvim",
		cond = not min_nvim("0.10"),
		opts = {},
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
		end,
	},

	-- !DEBUGGER
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
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
		build = (has_ts_cli and has_cc) and ":TSUpdate" or false,
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
				"elixir",
				"heex",
				"eex",
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
				-- needs the tree-sitter CLI (0.26+) and a C compiler on PATH (the
				-- NixOS config provides both). Then start core treesitter per buffer
				-- (the highlight/indent modules no longer exist).
				-- Without the toolchain nothing can be built, so fall back to the
				-- parsers committed under parsers/<sysname>-<machine>/ in this repo.
				-- Pointing nvim-treesitter's install_dir at that directory prepends it
				-- to the runtimepath, which is how Neovim finds parser/*.so and
				-- queries/, and makes get_installed() read its parser-info stamps. The
				-- install pass below then has nothing missing to build. The NixOS
				-- machines never take this branch, so they keep building their own
				-- into the usual site directory.
				local ts_config = require("nvim-treesitter.config")
				local can_build = has_ts_cli and has_cc
				local bundle
				if not can_build then
					local uname = vim.uv.os_uname()
					local dir = vim.fs.joinpath(
						vim.fn.stdpath("config"),
						"parsers",
						uname.sysname:lower() .. "-" .. uname.machine
					)
					if vim.fn.isdirectory(dir) == 1 then
						bundle = dir
						require("nvim-treesitter").setup({ install_dir = bundle })
					end
				end
				local installed = ts_config.get_installed("parsers")
				local missing = vim.tbl_filter(function(lang)
					return not vim.tbl_contains(installed, lang)
				end, languages)
				if #missing > 0 and can_build then
					require("nvim-treesitter").install(missing)
				elseif #missing > 0 then
					-- Cannot build, and no bundle for this platform (or an incomplete
					-- one). Say what is absent, what to install, and where a prebuilt
					-- .so would go.
					local lacking = {}
					if not has_ts_cli then
						table.insert(lacking, "the tree-sitter CLI")
					end
					if not has_cc then
						table.insert(lacking, "a C compiler (cc, gcc, clang)")
					end
					warn_at_startup(
						"nvim-treesitter cannot build parsers: "
							.. table.concat(lacking, " and ")
							.. " not found on PATH."
							.. "\nMissing parsers: "
							.. table.concat(missing, ", ")
							.. "\nDebian/Ubuntu: sudo apt install build-essential tree-sitter-cli"
							.. " (needs tree-sitter-cli 0.26 or newer)."
							.. "\nOr put prebuilt parsers in "
							.. (bundle or ts_config.get_install_dir("parser"))
							.. " (see README.md, \"Prebuilt tree-sitter parsers\")."
					)
				end
				-- Prose filetypes where list wrapping must stay with vim's own
				-- 'autoindent' + 'formatlistpat' (driven by vim-pencil's hard wrap).
				-- The treesitter markdown indentexpr collapses the hanging indent on
				-- the 3rd+ wrapped line of a list item, so keep TS *highlighting* here
				-- but not its indent.
				local no_ts_indent = { markdown = true, text = true }
				-- Filetypes where the builtin indent script beats the treesitter
				-- queries: nvim-treesitter's ocaml indents.scm over-indents after
				-- an application inside try/with. Keep the ftplugin's indentexpr
				-- (GetOCamlIndent) instead of replacing it.
				local builtin_indent = { ocaml = true, ocaml_interface = true }
				-- A parser that get_installed() reported but that fails to start is
				-- a broken one, typically a prebuilt .so this machine cannot load
				-- (other architecture, older glibc, older tree-sitter ABI). Silence
				-- here would look like a missing parser, so say so once per language
				-- with the loader's reason. Filetypes with no parser at all are the
				-- normal case and stay quiet.
				local reported = {}
				vim.api.nvim_create_autocmd("FileType", {
					callback = function(args)
						local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
						if not lang then
							return
						end
						local ok, err = pcall(vim.treesitter.start, args.buf, lang)
						if ok then
							if no_ts_indent[vim.bo[args.buf].filetype] then
								vim.bo[args.buf].indentexpr = ""
							elseif not builtin_indent[vim.bo[args.buf].filetype] then
								vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
							end
						elseif vim.tbl_contains(installed, lang) and not reported[lang] then
							reported[lang] = true
							-- start() only says "parser could not be created"; loading the
							-- parser on its own gives the dlopen reason.
							local loaded, why = pcall(vim.treesitter.language.add, lang)
							if not loaded then
								err = why
							end
							vim.notify(
								"nvim-treesitter: the " .. lang .. " parser is installed but does not load:\n"
									.. tostring(err):gsub("^.-:%d+: ", ""),
								vim.log.levels.WARN
							)
						end
					end,
				})
			else
				-- legacy master branch (Neovim < 0.12). It fetches parser sources
				-- with curl + tar (or git) and compiles them itself; the tree-sitter
				-- CLI is not involved. Without a compiler, ensure_installed would
				-- print one error per parser at every start, so install nothing and
				-- say so once. The parsers already in the site directory keep
				-- working. The prebuilt bundle in parsers/ is not an option here: it
				-- is built at tree-sitter ABI 15 against main's parser revisions,
				-- and master's queries expect its own.
				require("nvim-treesitter.configs").setup({
					ensure_installed = has_cc and languages or {},
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },
				})
				if not has_cc then
					local v = vim.version()
					warn_at_startup(
						"nvim-treesitter (master branch, for Neovim "
							.. v.major .. "." .. v.minor
							.. ") compiles parsers with a C compiler, and none was found on PATH (cc, gcc, clang)."
							.. "\nDebian/Ubuntu: sudo apt install build-essential curl"
							.. "\nParsers already in "
							.. vim.fn.stdpath("data") .. "/site/parser"
							.. " keep working; nothing new is built."
					)
				end
			end
		end,
	},

	-- !LSP
	{
		"neovim/nvim-lspconfig",
		-- On Neovim < 0.11, setup_lsp() (lspsetup.lua) uses the classic
		-- require("lspconfig")[server].setup() framework. Current lspconfig (v2.x)
		-- requires Neovim 0.10+ and warns that <0.11 support is deprecated and
		-- slated for removal in v3.0.0. Pin to v1.8.0 below 0.11 — the last
		-- release that supports Neovim 0.9 and the framework, with no deprecation
		-- nag. On 0.11+ track latest and use vim.lsp.config/enable instead.
		tag = vim.fn.has("nvim-0.11") == 0 and "v1.8.0" or nil,
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
	-- Schema catalog for yamlls (see lspsetup.lua): maps filenames like
	-- *openapi*.yml to the right JSON Schema for completion/validation.
	{ "b0o/schemastore.nvim" },

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
		-- rustaceanvim takes its settings from vim.g.rustaceanvim, read when the
		-- plugin loads, so set it in init rather than as a spec key.
		init = function()
			vim.g.rustaceanvim = {
				server = {
					default_settings = {
						["rust-analyzer"] = {
							cargo = { allFeatures = true },
						},
					},
				},
			}
		end,
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
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
		opts = { default_file_explorer = true },
	},

	-- Which Key - shortcut lookup
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
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
	{ "lewis6991/gitsigns.nvim", opts = {} },
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

			-- obsidian.nvim errors at setup if the workspace path is absent;
			-- create it so fresh machines without the vault still load nvim.
			vim.fn.mkdir(vim.fn.expand(vim.g.notes_root .. "/main"), "p")

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
				-- markview's defaults force conceallevel=3 on attach/enable,
				-- which overrides the conceallevel=2 set in init.lua and trips
				-- obsidian.nvim's UI check (it wants 1 or 2). Pin it back to 2 so
				-- both renderers agree; table rendering uses virtual text and is
				-- unaffected by the 2-vs-3 distinction.
				preview = {
					-- markview's default attach list also includes typst, rmd,
					-- quarto and asciidoc (spec.lua). Its global BufEnter autocmd
					-- then calls vim.treesitter.start(buf, ft) for those buffers;
					-- with no typst parser installed that assert throws on every
					-- .typ file. Restrict attachment to markdown, which is all
					-- this config renders. (`typst = { enable = false }` below only
					-- disables the renderer, not the attach.)
					filetypes = { "markdown" },
					callbacks = {
						on_attach = function(_, wins)
							for _, win in ipairs(wins) do
								vim.wo[win].conceallevel = 2
							end
						end,
						on_enable = function(_, wins)
							for _, win in ipairs(wins) do
								vim.wo[win].conceallevel = 2
							end
						end,
					},
				},
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
		opts = {},
	},

}, {
	-- Nothing here needs luarocks. Eleven plugins ship a rockspec, but lazy.nvim
	-- only reaches for luarocks when the build is not "simple" (rockspec.lua,
	-- is_simple_build): a builtin build with an explicit `modules` table, or
	-- dependencies beyond lua and other plugins. oxocarbon.nvim was the one that
	-- qualified, and it is gone; the rest declare copy_directories only, so lazy
	-- uses the plain git clone. Keep this off so the next plugin that adds a
	-- modules table does not break machines without a Lua 5.1 toolchain.
	rocks = { enabled = false },
})
