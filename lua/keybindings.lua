vim.g.mapleader = " "
local builtin = require("telescope.builtin")
local wk = require("which-key")

-- Tab shortcuts
wk.add {
    { "<C-Esc>", builtin.lsp_document_symbols, desc="Show all symbols in buffer", mode="n" },
    { "<S-Tab>", function() builtin.buffers() end, desc="Show buffers", mode="n" }
}

-- Finding stuff
wk.add {
    { "<leader>f", group = "Find..." },
    { "<leader>ff", builtin.find_files, desc="Find file", mode="n" },
    { "<leader>fg", builtin.live_grep, desc="Grep files", mode="n" },
    { "<leader>fh", builtin.help_tags, desc="Find help", mode="n" }
}

-- Going places
wk.add {
    { "<leader>g", group = "Go to..." },
    { "<leader>ge", "<CMD>Oil<CR>", desc="Go to directory", mode="n" },
    { "<leader>gw", "<CMD>WikiIndex<CR>", desc="Go to wiki", mode="n" },
    { "<leader>gd", builtin.lsp_definitions, desc="Go to definitions", mode="n" },
    { "<leader>gr", builtin.lsp_references, desc="Go to references", mode="n" },
    { "<leader>gt", builtin.treesitter, desc="Go to treesitter", mode="n" }
}

-- Wiki
wk.add {
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
    { "<F6>", require("dap").stop, desc="Stop debugger", mode="n" },
    { "<F7>", require("dap").step_into, desc="Step into", mode="n" },
    { "<F8>", require("dap").step_over, desc="Step over", mode="n" },

    { "<F9>", require("dap").toggle_breakpoint, desc="Toggle breakpoint", mode="n" },
    { "<F10>", function() require("dapui").float_element("breakpoints") end, desc="Show breakpoints", mode="n" },
    { "<F11>", builtin.diagnostics, desc="Show diagnostics", mode="n" },
    { "<F12>", builtin.lsp_definitions, desc="Show definitions", mode="n" },
    { "<C-F12>", vim.lsp.buf.hover, desc="Hover documentation", mode="n" }
}

-- LSP & Code Actions
wk.add({
	{ "<leader>q", group = "Code Actions" },
	{ "<leader>qq", vim.lsp.buf.rename, desc = "Rename Symbol", mode = "n" },
	{ "<leader>qa", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
	{ "<leader>qd", builtin.diagnostics, desc = "Workspace Diagnostics", mode = "n" },
	{ "<leader>qe", vim.diagnostic.open_float, desc = "Line Diagnostics", mode = "n" },
})
