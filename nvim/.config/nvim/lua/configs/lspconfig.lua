require("nvchad.configs.lspconfig").defaults()

local ok, schemastore = pcall(require("schemastore"))
local yaml_schemas = ok and schemastore.yaml.schemas() or {}

vim.lsp.config("yamlls", {

	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" },
			schemas = yaml_schemas,

			validate = true,
			format = { enable = true },
			completion = true,
			hover = true,
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
				format = { enable = false },
			},
		},
	},
})

local servers = { "html", "cssls", "yamlls", "lua_ls" }
vim.lsp.enable(servers)
