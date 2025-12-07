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

-- Capabilities (for nvim-cmp)
local capabilities = require("cmp_nvim_lsp").default_capabilities()


-- LSP configuration / setup
local function setup_lsp(server_name, config)
    config = config or {}

    -- Inject cmp capabilities, if not already present
    if not config.capabilities then
        config.capabilities = capabilities
    end

    if vim.fn.has("nvim-0.11") == 1 then
        if next(config) then
            vim.lsp.config(server_name, config)
        end
        vim.lsp.enable(server_name)
    else
        require("lspconfig")[server_name].setup(config)
    end
end


-- !LANGAUGES
-- Rust is handled with rustaceanvim
setup_lsp("zls", {})   -- Zig 
setup_lsp("gopls", {}) -- Golang
setup_lsp("pylsp", {
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
