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
-- Python: pylsp isn't installed globally — it lives inside each project's
-- environment (a uv `.venv` or a `nix develop` flake shell). Resolve the
-- interpreter in priority order: an activated virtualenv, a project-local uv
-- `.venv` at the cwd (works even when not activated), then python3 / python on
-- PATH (covers a flake devshell). Only accept an interpreter that can actually
-- import pylsp — `python` existing isn't enough, the global one is bare and the
-- server would die on startup. Returns nil otherwise so pylsp stays a clean
-- no-op. Resolved at startup against the cwd, so launch nvim from the project
-- root — or after changing dir / creating the venv, re-resolve with
-- `:PylspReload` (no nvim restart needed).
-- Interpreter path inside a virtualenv root differs by OS: POSIX venvs put it
-- at `<root>/bin/python`, Windows venvs at `<root>\Scripts\python.exe`.
local function venv_python(root)
	if vim.fn.has("win32") == 1 then
		return root .. "\\Scripts\\python.exe"
	end
	return root .. "/bin/python"
end

local function pylsp_python()
	local candidates = {}
	if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
		table.insert(candidates, venv_python(vim.env.VIRTUAL_ENV))
	end
	table.insert(candidates, venv_python(vim.fn.getcwd() .. "/.venv"))
	table.insert(candidates, "python3")
	table.insert(candidates, "python")

	for _, py in ipairs(candidates) do
		if vim.fn.executable(py) == 1 then
			-- find_spec probes availability without paying pylsp's full import
			vim.fn.system({ py, "-c", "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('pylsp') else 1)" })
			if vim.v.shell_error == 0 then
				return py
			end
		end
	end
	return nil
end

local function start_pylsp()
	local py = pylsp_python()
	if not py then
		return false
	end
	setup_lsp("pylsp", {
		cmd = { py, "-m", "pylsp" },
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
	return py
end

start_pylsp()

-- Re-resolve the interpreter and restart pylsp without restarting nvim — for
-- switching venvs mid-session or creating the venv after nvim was opened. Pure
-- Lua, no external tooling (unlike fd-based venv pickers), so it works on
-- Windows too. Stops running pylsp clients, re-runs the resolver, and reloads
-- open buffers so the new server attaches.
vim.api.nvim_create_user_command("PylspReload", function()
	for _, client in ipairs(vim.lsp.get_clients({ name = "pylsp" })) do
		vim.lsp.stop_client(client.id, true)
	end
	local py = start_pylsp()
	if py then
		vim.cmd("silent! bufdo if &filetype ==# 'python' | edit | endif")
		vim.notify("pylsp: " .. py, vim.log.levels.INFO)
	else
		vim.notify("pylsp: no interpreter with pylsp found (checked $VIRTUAL_ENV, ./.venv, PATH)", vim.log.levels.WARN)
	end
end, { desc = "Re-resolve venv and restart pylsp" })
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
