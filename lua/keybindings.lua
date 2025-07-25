vim.g.mapleader = " "
local builtin = require("telescope.builtin")
local wk = require("which-key")

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


-- Debugging
-- local _dap = require("dap")
-- local _dapui = require("dapui")
wk.add {
    { "<leader>b", require("dap").toggle_breakpoint, desc="Set breakpoint", mode="n" },
    { "<F1>", require("dapui").toggle, desc="Show debugger UI", mode="n" }
}

-- Additional wiki key bindings
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
