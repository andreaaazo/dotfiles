require("nvchad.configs.lspconfig").defaults()

local ok, schemastore = pcall(require("schemastore"))
local yaml_schemas = ok and schemastore.yaml.schemas() or {}

-- Ruff Language Server (linter/code actions)
vim.lsp.config("ruff", {
  init_options = {
    settings = {
      configuration = vim.fn.expand("~/.config/ruff/pyproject.toml"),
    },
  },
})

-- Pyright (type checking)
vim.lsp.config("pyright", {
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = "strict",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Disable Ruff hover capability, use Pyright instead
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Disable hover capability from Ruff",
})

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

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
})

local servers = { "html", "cssls", "yamlls", "lua_ls", "pyright", "ruff", "clangd" }
vim.lsp.enable(servers)
