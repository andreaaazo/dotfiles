local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    json = { "prettier" },
    yaml = { "prettier" },
    yml = { "prettier" },
    python = { "ruff_organize_imports", "ruff_fix", "black" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },

  formatters = {
    prettier = {
      prepend_args = {
        "--config",
        vim.fn.expand("~/.config/prettier/.prettierrc.json"),
      },
    },
    stylua = {
      prepend_args = {
        "--config-path",
        vim.fn.expand("~/.config/stylua/stylua.toml"),
      },
    },
    ["clang-format"] = {
      prepend_args = {
        "-style=file:" .. vim.fn.expand("~/.config/clang-format/.clang-format"),
      },
    },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = false,
  },
}

return options
