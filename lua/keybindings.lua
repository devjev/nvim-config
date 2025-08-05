vim.g.mapleader = " "
local builtin = require("telescope.builtin")
local wk = require("which-key")

-- Tab shortcuts
wk.add {
    { "<S-Tab>", function() builtin.buffers() end, desc="Show buffers", mode="n" }
}

-- Finding stuff
wk.add {
    { "<leader>f", group = "Find..." },
    { "<leader>ff", builtin.find_files, desc="Find file", mode="n" },
    { "<leader>fg", builtin.live_grep, desc="Grep files", mode="n" },
    { "<leader>fh", builtin.help_tags, desc="Find help", mode="n" },
    { "<leader>fs", group = "Find LSP symbols..." },
    {
        "<leader>fss",
        function()
            -- clangd/tsserver usually default to "utf-16" unless overridden, apparently
            builtin.lsp_document_symbols { position_encoding = "utf-16" }
        end,
        desc="Find all LSP symbols in buffer",
        mode="n"
    },
    { "<leader>fsu", builtin.lsp_references, desc="Find symbol use", mode="n" },
    { "<leader>fc", builtin.commands, desc="Find (and execute) commands", mode={ "n", "v"}, },
    { "<leader>fo", builtin.commands, desc="Find vim options", mode="n", },
}

-- Going places
wk.add {
    { "<leader>g", group = "Go to..." },
    { "<leader>go", "<CMD>Oil<CR>", desc="Go to file manager", mode="n" },
    { "<leader>gd", builtin.lsp_definitions, desc="Go to symbol definition", mode="n" },
}

-- Wiki
wk.add {
    { "<leader>w", group = "Wiki..." },
    { "<leader>wh", "<CMD>WikiIndex<CR>", desc="Wiki home", mode="n" },
    { "<leader>wj", "<CMD>WikiJournal<CR>", desc="Wiki journal", mode="n" },
    { "<leader>wp", "<CMD>WikiPages<CR>", desc="Wiki pages", mode="n" },
    { "<leader>wt", "<CMD>WikiTags<CR>", desc="Wiki tags", mode="n" }
}

local wiki_dir = vim.fn.expand("~/Wiki")

-- A function to search for text within all wiki files
local function search_wiki_content()
  require("telescope.builtin").live_grep({
    prompt_title = "< Grep Wiki >",
    search_dirs = { wiki_dir },
  })
end

wk.add {
    { "<leader>fw", search_wiki_content, desc="Find wiki content", mode="n" },
}

-- Debugging
wk.add {
    { "<F1>", require("dapui").toggle, desc="Show debugger UI", mode="n" },
    { "<F2>", function() require("dapui").float_element("scopes") end, desc="Show scopes", mode="n" },
    { "<F3>", function() require("dapui").float_element("watches") end, desc="Show watches", mode="n" },
    { "<F4>", function() require("dapui").float_element("stacks") end, desc="Show stacks", mode="n" },

    { "<F5>", require("dap").continue, desc="Run debugger to breakpoint", mode="n" },
    { "<F6>", require("dap").close, desc="Stop debugger", mode="n" },
    { "<F7>", require("dap").step_into, desc="Step into", mode="n" },
    { "<F8>", require("dap").step_over, desc="Step over", mode="n" },

    { "<F9>", require("dap").toggle_breakpoint, desc="Toggle breakpoint", mode="n" },
    { "<F10>", function() require("dapui").float_element("breakpoints") end, desc="Show breakpoints", mode="n" }
}

-- LSP & Code Actions
wk.add({
	{ "<leader>q", group = "Quick actions..." },
	{ "<leader>qq", vim.lsp.buf.rename, desc = "Rename symbol", mode = "n" },
	{ "<leader>qa", vim.lsp.buf.code_action, desc = "Code action", mode = { "n", "v" } },
	{ "<leader>qd", builtin.diagnostics, desc = "Show workspace diagnostics", mode = "n" },
	{ "<leader>qe", vim.diagnostic.open_float, desc = "Show line diagnostics", mode = "n" },
	{ "<leader>qf", builtin.quickfix, desc = "Show quickfix menu", mode = "n" },
	{ "<leader>qF", builtin.quickfixhistory, desc = "Show quickfix history", mode = "n" },

    -- Duplicate debugger keys to non-function keys
    { "<leader>qd", group = "Debugger" },
    { "<leader>qdd", require("dap").continue, desc="Run debugger to breakpoint", mode="n" },
    { "<leader>qdv", require("dapui").toggle, desc="Show debugger UI", mode="n" },
    { "<leader>qds", function() require("dapui").float_element("scopes") end, desc="Show scopes", mode="n" },
    { "<leader>qdw", function() require("dapui").float_element("watches") end, desc="Show watches", mode="n" },
    { "<leader>qdS", function() require("dapui").float_element("stacks") end, desc="Show stacks", mode="n" },

    { "<leader>qdD", require("dap").close, desc="Stop debugger", mode="n" },
    { "]D", require("dap").step_into, desc="Step into", mode="n" },
    { "]d", require("dap").step_over, desc="Step over", mode="n" },

    { "<leader>qdb", require("dap").toggle_breakpoint, desc="Toggle breakpoint", mode="n" },
    { "<leader>qdB", function() require("dapui").float_element("breakpoints") end, desc="Show breakpoints", mode="n" }
})

-- !GIT
wk.add({
    {
        "]c",
        function()
            if vim.wo.diff then
                return "]c"
            end
            vim.schedule(function()
                require("gitsigns").next_hunk()
            end)
            return "<Ignore>"
        end,
        desc = "Next change",
        mode = "n",
        expr = true
    },
    {
        "[c",
        function()
            if vim.wo.diff then
                return "[c"
            end
            vim.schedule(function()
                require("gitsigns").prev_hunk()
            end)
            return "<Ignore>"
        end,
        desc = "Previous change",
        mode = "n",
        expr = true
    },

    { "<leader>v", group = "Git..." },
    { "<leader>vv", "<CMD>Neogit<CR>", desc="Show git status", mode="n" },
    { "<leader>vc", "<CMD>DiffviewOpen<CR>", desc="Show git diff", mode="n" },
    { "<leader>vs", function() require("gitsigns").stage_hunk() end, desc = "Stage change", mode = { "n", "v" } },
    { "<leader>vr", function() require("gitsigns").reset_hunk() end, desc = "Reset change", mode = { "n", "v" } },
    { "<leader>vS", require("gitsigns").stage_buffer, desc = "Stage entire buffer", mode = "n" },
    { "<leader>vu", require("gitsigns").undo_stage_hunk, desc = "Undo stage change", mode = "n" },
    { "<leader>vR", require("gitsigns").reset_buffer, desc = "Reset changes in buffer", mode = "n" },
    { "<leader>vp", require("gitsigns").preview_hunk, desc = "Preview change", mode = "n" },
    { "<leader>vb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line", mode = "n" },
    { "<leader>vd", require("gitsigns").diffthis, desc = "Diff this", mode = "n" },
    { "<leader>vD", function() require("gitsigns").diffthis("~") end, desc = "Diff this ~", mode = "n" },
    { "<leader>vt", group = "Git toggle" },
    { "<leader>vtb", require("gitsigns").toggle_current_line_blame, desc = "Toggle blame line", mode = "n" },
    { "<leader>vtd", require("gitsigns").toggle_deleted, desc = "Toggle deleted", mode = "n" },
})
