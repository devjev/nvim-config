-- Completion
local cmp = require("cmp")
cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<c-b>"] = cmp.mapping.scroll_docs(-4),
		["<c-f>"] = cmp.mapping.scroll_docs(4),
		["<c-space>"] = cmp.mapping.complete(),
		["<c-e>"] = cmp.mapping.abort(),
		["<cr>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
	}),
	enabled = function()
		local buf_file_type = vim.bo.filetype
		local enabled_filetypes = {
			"javascript",
			"python",
			"elixir",
			"erlang",
			"rust",
			"c",
			"markdown",
			"bash",
			"lua",
			"ocaml",
			"zig",
			"go",
			"gopls",
			"terraform",
		}
		return vim.tbl_contains(enabled_filetypes, buf_file_type)
	end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")


-- !LANGAUGES
-- Zig
lspconfig.zls.setup({ capabilities = capabilities })

-- Rust 
-- This is not needed with a rustaceanvim
-- lspconfig.rust_analyzer.setup({
-- 	settings = {
-- 		["rust-analyzer"] = {},
-- 	}
-- })

-- Golang
lspconfig.gopls.setup({})

-- Python
lspconfig.pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true,
                    ignore = { "E501", "W503", "W391", "E704" },
                    maxLineLength = 120,
                }
            }
        }
    }
})

