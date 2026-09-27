local wk = require("which-key")
local builtin = require("telescope.builtin")

-- !TAB
wk.add({
	{
		"<S-Tab>",
		function()
			builtin.buffers()
		end,
		desc = "Show buffers",
	},
})

-- !FIND
wk.add({
	{ "<leader>f", group = "Find...", icon = "🔎" },
	{ "<leader>ff", builtin.find_files, desc = "Find files" },
	{ "<leader>fg", builtin.live_grep, desc = "Grep files" },
	{ "<leader>fh", builtin.help_tags, desc = "Find help" },
	{ "<leader>fs", group = "Find LSP symbols..." },
	{
		"<leader>fss",
		function()
			-- clangd/tsserver usually default to "utf-16" unless overridden, apparently
			builtin.lsp_document_symbols({ position_encoding = "utf-16" })
		end,
		desc = "Find all symbols in buffer",
	},
	{ "<leader>fsu", builtin.lsp_references, desc = "Find all symbol uses" },
	{ "<leader>fC", builtin.commands, desc = "Find Vim commands", mode = { "n", "v" } },
	{ "<leader>fo", builtin.vim_options, desc = "Find Vim options" },
})

-- !GO
wk.add({
	{ "<leader>g", group = "Go to...", icon = "🚶" },
	{ "<leader>go", "<CMD>Oil<CR>", desc = "Go to file manager" },
	{ "<leader>gd", builtin.lsp_definitions, desc = "Go to symbol definition" },
	{ "<leader>gz", "<CMD>ZenMode<CR>", desc = "Go to zen mode" },
})

-- !PREVIEW
wk.add({
	{ "<leader>p", group = "Preview..." },
	{ "<leader>po", "<CMD>OmniPreview start<CR>", desc = "Preview start" },
	{ "<leader>pc", "<CMD>OmniPreview stop<CR>", desc = "Preview stop" },
	{ "<leader>pm", "<CMD>Markview Toggle<CR>", desc = "Toggle markdown render" },
})

-- !TABS
wk.add({
	{ "<leader>t", group = "Tabs...", icon = "📑" },
	{ "<leader>tn", "<CMD>$tabnew<CR>", desc = "Create new tab" },
	{ "<leader>tc", "<CMD>tabclose<CR>", desc = "Close tab" },
})

-- !NOTES
wk.add({
	{ "<leader>n", group = "Notes...", icon = "🗒️" },
	{ "<leader>nn", "<CMD>Obsidian dailies -2 2<CR>", icon = "📆", desc = "Daily notes" },
	{ "<leader>ns", "<CMD>Obsidian quick_switch<CR>", icon = "🚦", desc = "Quick switch between notes" },
	{ "<leader>ng", "<CMD>Obsidian follow_link<CR>", icon = "🚶", desc = "Follow link" },
	{ "<leader>nf", "<CMD>Obsidian search<CR>", icon = "🔎", desc = "Search" },

	{ "<leader>nl", group = "Link...", icon = "🔗" },
	{ "<leader>nla", "<CMD>Obsidian link<CR>", icon = "🖇️", desc = "Add link", mode = { "n", "v" } },
	{ "<leader>nln", "<CMD>Obsidian link_new<CR>", icon = "🆕", desc = "Link to new page", mode = { "n", "v" } },

	{ "<leader>np", "<CMD>Obsidian paste_img<CR>", icon = "🖼️", desc = "Paste image from clipboard" },
	{ "<leader>nz", "<CMD>Obsidian toc<CR>", icon = "📄", desc = "Table of contents" },
	{ "<leader>nc", "<CMD>Obsidian toggle_checkbox<CR>", icon = "✅", desc = "Toggle checkbox" },
	{ "<leader>nb", "<CMD>Obsidian backlinks<CR>", icon = "🌍", desc = "Backlinks" },
	{ "<leader>nt", "<CMD>Obsidian tags<CR>", icon = "🏷️", desc = "Tags" },
	{ "<leader>ne", "<CMD>Obsidian new<CR>", icon = "✍️", desc = "New note" },
})


-- LSP & Code Actions
wk.add({
	{ "<leader>q", group = "Quick actions...", icon = "🧨" },
	{ "<leader>qq", vim.lsp.buf.rename, desc = "Rename symbol" },
	{ "<leader>qa", vim.lsp.buf.code_action, desc = "Code action", mode = { "n", "v" } },
	{ "<leader>qf", builtin.quickfix, desc = "Show quickfix menu" },
	{ "<leader>qF", builtin.quickfixhistory, desc = "Show quickfix history" },
	{ "<leader>qW", builtin.diagnostics, desc = "What's wrong? (project)" },
	{ "<leader>qw", vim.diagnostic.open_float, desc = "What's wrong? (cursor)" },
	-- The debugger (F-keys, <leader>qd*, ]d, ]D) and REPL (<leader>qr) bindings
	-- are in lazysetup.lua, in the nvim-dap and iron specs, so those plugins
	-- load on first use. The group is declared here for which-key.
	{ "<leader>qd", group = "Debugger", icon = "🐞" },
})

-- !GIT
local gs = require("gitsigns")

wk.add({
	{ "<leader>v", group = "Git...", icon = "💽" },
	{ "<leader>vc", "<CMD>DiffviewOpen<CR>", desc = "Show git diff" },
	{ "<leader>vn", gs.nav_hunk, desc = "Navigate changes" },
	{ "<leader>vh", builtin.git_commits, desc = "Show git commits" },
	{ "<leader>vy", "<CMD>G push<CR>", desc = "Git push" }, -- y for yolo
	{ "<leader>vs", gs.stage_hunk, desc = "Stage change", mode = { "n", "v" } },
	{ "<leader>vr", gs.reset_hunk, desc = "Reset change", mode = { "n", "v" } },
	{ "<leader>vS", gs.stage_buffer, desc = "Stage entire buffer" },
	{ "<leader>vR", gs.reset_buffer, desc = "Reset changes in buffer" },
	{ "<leader>vp", gs.preview_hunk, desc = "Preview change" },
	{
		"<leader>vb",
		function()
			gs.blame_line({ full = true })
		end,
		desc = "Blame line",
	},
	{ "<leader>vd", gs.diffthis, desc = "Diff this" },
	{ "<leader>vt", group = "Git toggle" },
	{ "<leader>vtb", gs.toggle_current_line_blame, desc = "Toggle blame line" },
})

-- !COLORS
local function toggle_colorscheme()
	if vim.g.colors_name == vim.g.dark_colorscheme then
		vim.cmd([[set bg=light]])
		vim.cmd("colorscheme " .. vim.g.light_colorscheme)
	else
		vim.cmd([[set bg=dark]])
		vim.cmd("colorscheme " .. vim.g.dark_colorscheme)
	end
end

local function toggle_termguicolors()
	if vim.opt.termguicolors:get() then
		-- Switch to terminal colors mode with default
		vim.opt.termguicolors = false
		vim.cmd("colorscheme default")
		vim.notify("Terminal colors (default)", vim.log.levels.INFO)
	else
		-- Switch back to GUI colors with default theme
		vim.opt.termguicolors = true
		vim.cmd("colorscheme " .. vim.g.dark_colorscheme)
		vim.notify("GUI colors (" .. vim.g.dark_colorscheme .. ")", vim.log.levels.INFO)
	end
end

wk.add({
	{ "<leader>c", group = "Color...", icon = "🎨" },
	{ "<leader>cc", toggle_colorscheme, desc = "Toggle dark/light colorscheme" },
	{ "<leader>ct", toggle_termguicolors, desc = "Toggle GUI/terminal colors" },
	{ "<leader>cp", "<CMD>CccPick<CR>", desc = "Pick a color", mode = { "n", "v" } },
	{ "<leader>cf", builtin.colorscheme, desc = "Pick a colorscheme" },
})

