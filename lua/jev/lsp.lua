local navic = require('nvim-navic') -- Bottom bar

local on_attach = function(client, bufnr)
	navic.attach(client, bufnr)
	local opts = { noremap=true, silent=true }
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cd', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
end

local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<c-b>'] = cmp.mapping.scroll_docs(-4),
		['<c-f>'] = cmp.mapping.scroll_docs(4),
		['<c-space>'] = cmp.mapping.complete(),
		['<c-e>'] = cmp.mapping.abort(),
		['<cr>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
	}),
	enabled = function()
		local buf_file_type = vim.bo.filetype
		local enabled_filetypes = {
			'javascript',
			'python',
			'elixir',
			'erlang',
			'rust',
			'c',
			'markdown',
			'bash',
			'lua',
			'ocaml',
			'zig',
		}
		return vim.tbl_contains(enabled_filetypes, buf_file_type)
	end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

-- Elixir
local elixir_ls_path = os.getenv('ELIXIR_LS') or 'opt/homebrew/Cellar/elixir-ls/0.17.10/bin/elixir-ls'
lspconfig.elixirls.setup({
  cmd = { elixir_ls_path },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Zig
lspconfig.zls.setup({ capabilities = capabilities })

-- Python
local python_fallback = os.getenv('NVIM_PYTHON_FALLBACK')
if python_fallback ~= nil then
    local function get_config_dir()
        local str = debug.getinfo(2, "S").source:sub(2)
        local path = str:match("(.*/)")
        return path
    end
    
    local custom_jedi_script = get_config_dir() .. 'jedi_fallback.py'
    
    lspconfig.jedi_language_server.setup({
    	cmd = { 'python', custom_jedi_script },
    	on_attach = on_attach,
    })
else
	lspconfig.jedi_language_server.setup({})
end


-- Typescript
lspconfig.tsserver.setup({})

-- Rust 
lspconfig.rust_analyzer.setup({
	settings = {
		['rust-analyzer'] = {},
	}
})

-- Ocaml
lspconfig.ocamllsp.setup({})

-- TODO set up Lua LSP
