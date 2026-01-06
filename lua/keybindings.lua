vim.g.mapleader = " "
local wk = require("which-key")
local builtin = require("telescope.builtin")
local iron_core = require("iron.core") -- REPL

-- !TAB
wk.add({
	{
		"<S-Tab>",
		function()
			builtin.buffers()
		end,
		desc = "Show buffers",
		mode = "n",
	},
})

-- !FIND
wk.add({
	{ "<leader>f", group = "Find..." },
	{ "<leader>ff", builtin.find_files, desc = "Find files", mode = "n" },
	{ "<leader>fg", builtin.live_grep, desc = "Grep files", mode = "n" },
	{ "<leader>fh", builtin.help_tags, desc = "Find help", mode = "n" },
	{ "<leader>fs", group = "Find LSP symbols..." },
	{
		"<leader>fss",
		function()
			-- clangd/tsserver usually default to "utf-16" unless overridden, apparently
			builtin.lsp_document_symbols({ position_encoding = "utf-16" })
		end,
		desc = "Find all symbols in buffer",
		mode = "n",
	},
	{ "<leader>fsu", builtin.lsp_references, desc = "Find all symbol uses", mode = "n" },
	{ "<leader>fC", builtin.commands, desc = "Find Vim commands", mode = { "n", "v" } },
	{ "<leader>fo", builtin.vim_options, desc = "Find Vim options", mode = "n" },
})

-- !GO
wk.add({
	{ "<leader>g", group = "Go to...", icon = "➤" },
	{ "<leader>go", "<CMD>Oil<CR>", desc = "Go to file manager", mode = "n" },
	{ "<leader>gd", builtin.lsp_definitions, desc = "Go to symbol definition", mode = "n" },
	{ "<leader>gz", "<CMD>ZenMode<CR>", desc = "Go to zen mode", mode = "n" },
})

-- !PREVIEW
wk.add({
	{ "<leader>p", group = "Preview..." },
	{ "<leader>po", "<CME>OmniPreview start<CR>", desc = "Preview start", mode = "n" },
	{ "<leader>pc", "<CME>OmniPreview stop<CR>", desc = "Preview start", mode = "n" },
})

-- !TABS
wk.add({
	{ "<leader>t", group = "Tabs...", icon = "➤" },
	{ "<leader>tn", "<CMD>$tabnew<CR>", desc = "Create new tab", mode = "n" },
	{ "<leader>tc", "<CMD>tabclose<CR>", desc = "Close tab", mode = "n" },
})

-- !NOTES
wk.add({
	{ "<leader>n", group = "Notes...", icon = "🗒️" },
	{ "<leader>nn", "<CMD>ObsidianDailies<CR>", icon = "📆", desc = "Daily notes", mode = "n" },
	{ "<leader>ns", "<CMD>ObsidianQuickSwitch<CR>", icon = "🚦", desc = "Quick switch between notes", mode = "n" },
	{ "<leader>ng", "<CMD>ObsidianFollowLink<CR>", icon = "🚶", desc = "Follow link", mode = "n" },
	{ "<leader>ng", "<CMD>ObsidianSearch<CR>", icon = "🔎", desc = "Search", mode = "n" },

	{ "<leader>nl", group = "Link...", icon = "🔗" },
	{ "<leader>nla", "<CMD>ObsidianLink<CR>", icon = "🖇️", desc = "Add link", mode = { "n", "v" } },
	{ "<leader>nla", "<CMD>ObsidianLinkNew<CR>", icon = "🆕", desc = "Link to new page", mode = { "n", "v" } },

	{ "<leader>np", "<CMD>ObisidianPasteImg<CR>", icon = "🖼️", desc = "Paste image from clipboard", mode = "n" },
	{ "<leader>nt", "<CMD>ObisidianTOC<CR>", icon = "📄", desc = "Paste image from clipboard", mode = "n" },
	{ "<leader>nc", "<CMD>ObisidianToggleCheckbox<CR>", icon = "✅", desc = "Toggle checkbox", mode = "n" },
})


-- Debugging
wk.add({
	{ "<F1>", require("dapui").toggle, desc = "Show debugger UI", mode = "n" },
	{
		"<F2>",
		function()
			require("dapui").float_element("scopes")
		end,
		desc = "Show scopes",
		mode = "n",
	},
	{
		"<F3>",
		function()
			require("dapui").float_element("watches")
		end,
		desc = "Show watches",
		mode = "n",
	},
	{
		"<F4>",
		function()
			require("dapui").float_element("stacks")
		end,
		desc = "Show stacks",
		mode = "n",
	},

	{ "<F5>", require("dap").continue, desc = "Run debugger to breakpoint", mode = "n" },
	{ "<F6>", require("dap").close, desc = "Stop debugger", mode = "n" },
	{ "<F7>", require("dap").step_into, desc = "Step into", mode = "n" },
	{ "<F8>", require("dap").step_over, desc = "Step over", mode = "n" },

	{ "<F9>", require("dap").toggle_breakpoint, desc = "Toggle breakpoint", mode = "n" },
	{
		"<F10>",
		function()
			require("dapui").float_element("breakpoints")
		end,
		desc = "Show breakpoints",
		mode = "n",
	},
	{
		"<F11>",
		function()
			require("dapui").float_element("repl")
		end,
		desc = "Show REPL",
		mode = "n",
	},
})

-- LSP & Code Actions
wk.add({
	{ "<leader>q", group = "Quick actions..." },
	{ "<leader>qq", vim.lsp.buf.rename, desc = "Rename symbol", mode = "n" },
	{ "<leader>qa", vim.lsp.buf.code_action, desc = "Code action", mode = { "n", "v" } },
	{ "<leader>qf", builtin.quickfix, desc = "Show quickfix menu", mode = "n" },
	{ "<leader>qF", builtin.quickfixhistory, desc = "Show quickfix history", mode = "n" },
	{ "<leader>qW", builtin.diagnostics, desc = "What's wrong? (project)", mode = "n" },
	{ "<leader>qw", vim.diagnostic.open_float, desc = "What's wrong? (cursor)", mode = "n" },

	-- Duplicate debugger keys to non-function keys
	{ "<leader>qd", group = "Debugger" },
	{ "<leader>qdd", require("dap").continue, desc = "Run debugger to breakpoint", mode = "n" },
	{ "<leader>qdv", require("dapui").toggle, desc = "Show debugger UI", mode = "n" },
	{
		"<leader>qds",
		function()
			require("dapui").float_element("scopes")
		end,
		desc = "Show scopes",
		mode = "n",
	},
	{
		"<leader>qdw",
		function()
			require("dapui").float_element("watches")
		end,
		desc = "Show watches",
		mode = "n",
	},
	{
		"<leader>qdS",
		function()
			require("dapui").float_element("stacks")
		end,
		desc = "Show stacks",
		mode = "n",
	},
	{ "<leader>qdr", "<CMD>DapToggleRepl<CR>", desc = "Show REPL", mode = "n" },

	{ "<leader>qdD", require("dap").close, desc = "Stop debugger", mode = "n" },
	{ "]D", require("dap").step_into, desc = "Step into", mode = "n" },
	{ "]d", require("dap").step_over, desc = "Step over", mode = "n" },

	{ "<leader>qdb", require("dap").toggle_breakpoint, desc = "Toggle breakpoint", mode = "n" },
	{
		"<leader>qdB",
		function()
			require("dapui").float_element("breakpoints")
		end,
		desc = "Show breakpoints",
		mode = "n",
	},

	-- REPL
	{ "<leader>qr", "<CMD>IronRepl<CR>", desc = "Show REPL", mode = "n" },
	{
		"<leader>qr",
		function()
			iron_core.visual_send()
			vim.cmd([[IronRepl]])
		end,
		desc = "Send to REPL",
		mode = "v",
	},
})

-- !GIT
local gs = require("gitsigns")

wk.add({
	{ "<leader>v", group = "Git..." },
	{ "<leader>vv", "<CMD>Neogit<CR>", desc = "Show neogit", mode = "n" },
	{ "<leader>vc", "<CMD>DiffviewOpen<CR>", desc = "Show git diff", mode = "n" },
	{ "<leader>vn", gs.nav_hunk, desc = "Navigate changes", mode = "n" },
	{ "<leader>vh", builtin.git_commits, desc = "Show git commits", mode = "n" },
	{ "<leader>vy", "<CMD>G push<CR>", desc = "Git push", mode = "n" }, -- y for yolo
	{ "<leader>vs", gs.stage_hunk, desc = "Stage change", mode = { "n", "v" } },
	{ "<leader>vr", gs.reset_hunk, desc = "Reset change", mode = { "n", "v" } },
	{ "<leader>vS", gs.stage_buffer, desc = "Stage entire buffer", mode = "n" },
	{ "<leader>vR", gs.reset_buffer, desc = "Reset changes in buffer", mode = "n" },
	{ "<leader>vp", gs.preview_hunk, desc = "Preview change", mode = "n" },
	{
		"<leader>vb",
		function()
			gs.blame_line({ full = true })
		end,
		desc = "Blame line",
		mode = "n",
	},
	{ "<leader>vd", gs.diffthis, desc = "Diff this", mode = "n" },
	{ "<leader>vt", group = "Git toggle" },
	{ "<leader>vtb", gs.toggle_current_line_blame, desc = "Toggle blame line", mode = "n" },
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

wk.add({
	{ "<leader>c", group = "Color..." },
	{ "<leader>cc", toggle_colorscheme, desc = "Toggle dark/light colorscheme", mode = "n" },
	{ "<leader>cp", "<CMD>CccPick<CR>", desc = "Pick a color", mode = { "n", "v" } },
	{ "<leader>cf", builtin.colorscheme, desc = "Pick a colorscheme", mode = "n" },
})
