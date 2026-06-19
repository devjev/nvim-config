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
			"typescript",
			"typescriptreact",
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
			"alloy",
			"quint",
		}
		return vim.tbl_contains(enabled_filetypes, buf_file_type)
	end,
})

-- Capabilities (for nvim-cmp)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- LSP configuration / setup
local function setup_lsp(server_name, config)
	config = config or {}

	-- When an explicit cmd is given, only proceed if its executable is on PATH,
	-- so a server that isn't installed is a silent no-op instead of erroring on
	-- every matching buffer. Servers without a cmd rely on lspconfig's default.
	if config.cmd and vim.fn.executable(config.cmd[1]) ~= 1 then
		return
	end

	-- Inject cmp capabilities, if not already present
	if not config.capabilities then
		config.capabilities = capabilities
        config.capabilities.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }
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
setup_lsp("zls", {}) -- Zig
setup_lsp("gopls", {}) -- Golang
setup_lsp("lua_ls", {}) -- Lua
setup_lsp("pylsp", {
    cmd = { "python", "-m", "pylsp" },
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					enabled = true,
					ignore = { "E501", "W503", "W391", "E704" },
					maxLineLength = 120,
				},
			},
		},
	},
})
setup_lsp("ts_ls", {})
setup_lsp("nixd", {
    cmd = { "nixd" },
})
setup_lsp("elixirls", {}) -- Elixir
setup_lsp("erlangls", {}) -- Erlang

-- Alloy & Quint: neovim doesn't know these extensions, so register them first.
-- Both servers are optional and only start if their binary is installed.
vim.filetype.add({
	extension = {
		als = "alloy",
		qnt = "quint",
	},
})

setup_lsp("alloy", {
	cmd = { "alloy-language-server", "--stdio" },
	filetypes = { "alloy" },
	root_markers = { ".git" },
})

setup_lsp("quint", {
	cmd = { "quint-language-server", "--stdio" },
	filetypes = { "quint" },
	root_markers = { ".git" },
})
