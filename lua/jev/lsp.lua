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
			'go',
			'gopls',
			'terraform',
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


-- Rust 
lspconfig.rust_analyzer.setup({
	settings = {
		['rust-analyzer'] = {},
	}
})

-- Ocaml
lspconfig.ocamllsp.setup({})


-- Golang
lspconfig.gopls.setup({})

-- Erlang
lspconfig.erlangls.setup({})

-- TODO set up Lua LSP

lspconfig.terraformls.setup({})
