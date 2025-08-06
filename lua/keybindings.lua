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
    { "<leader>ff", builtin.find_files, desc="Find files", mode="n" },
    { "<leader>fg", builtin.live_grep, desc="Grep files", mode="n" },
    { "<leader>fh", builtin.help_tags, desc="Find help", mode="n" },
    { "<leader>fs", group = "Find objects..." },
    {
        "<leader>fss",
        function()
            -- clangd/tsserver usually default to "utf-16" unless overridden, apparently
            builtin.lsp_document_symbols { position_encoding = "utf-16" }
        end,
        desc="Find all LSP symbols in buffer",
        mode="n"
    },
    { "<leader>fsu", builtin.lsp_references, desc="Find object use", mode="n" },
    { "<leader>fc", builtin.commands, desc="Find (and execute) commands", mode={ "n", "v"}, },
    { "<leader>fo", builtin.vim_options, desc="Find vim options", mode="n", },
}

-- Going places
wk.add {
    { "<leader>g", group = "Go to...", icon = "➤" },
    { "<leader>go", "<CMD>Oil<CR>", desc="Go to file manager", mode="n" },
    { "<leader>gd", builtin.lsp_definitions, desc="Go to symbol definition", mode="n" },
}

-- !WIKI
-- wiki.vim is great, but it's keybinding descriptions are not that good. 
-- I am going to do my own keybindings using whichkey and provide my own 
-- description.
--
-- One extra problem here are buffer local bindings, i.e. bindings which 
-- are valid only for a particular buffer. The condition if a file is valid 
-- or not is defined in the plugin and I don't know that condition. I also 
-- don't want to try to fudge it by myself.
vim.g.wiki_mappings_use_defaults = "local"

-- Also, we are going to use the Telescope version of wiki default commands.
local wiki_telescope = require("wiki.telescope")
vim.g.wiki_select_method = {
    pages = wiki_telescope.pages,
    tags  = wiki_telescope.tags,
    toc   = wiki_telescope.toc,
    links = wiki_telescope.links,
}

wk.add {
    { "<leader>w", group = "Wiki...", icon = "Ⓦ " },
    { "<leader>ww", "<CMD>WikiIndex<CR>", desc = "Wiki home", mode = "n" },
    { "<leader>wj", "<CMD>WikiJournal<CR>", desc = "Wiki journal", mode = "n" },
    { "<leader>wp", "<CMD>WikiPages<CR>", desc = "Wiki pages", mode = "n" },
    { "<leader>wt", "<CMD>WikiTags<CR>", desc = "Wiki tags", mode = "n" },
}

local wiki_dir = vim.fn.expand("~/Wiki")
local journal_dir = vim.fn.expand("~/Wiki/journal")

local function wiki_search(title, dir)
    local result = function()
        builtin.live_grep({
            prompt_title = title,
            search_dirs = { dir },
        })
    end
    return result
end

local function search_todos()
    builtin.live_grep({
        prompt_title = "Find TODOs",
        search_dirs = { wiki_dir },
        default_text = "- \\[ \\]",
    })
end

wk.add {
	{ "<leader>wf", group = "Find in wiki..." },
    { "<leader>wff", wiki_search("Find in wiki", wiki_dir), desc="Find in wiki", mode="n" },
    { "<leader>wfj", wiki_search("Find in journal", journal_dir), desc="Find in journal", mode="n" },
    { "<leader>wft", search_todos, desc="Find todos", mode="n" },
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
    { "<leader>vv", "<CMD>Neogit<CR>", desc="Show neogit", mode="n" },
    { "<leader>vc", "<CMD>DiffviewOpen<CR>", desc="Show git diff", mode="n" },
    { "<leader>vh", builtin.git_commits, desc="Show git commits", mode="n" },
    { "<leader>vy", "<CMD>G push<CR>", desc="Git push", mode="n" },  -- y for yolo
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
