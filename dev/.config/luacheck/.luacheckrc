return {
  std = "luajit",
  globals = { "vim" },

  max_line_length = 120,
  max_cyclomatic_complexity = 12,

  exclude_files = {
    ".git/",
    "node_modules/",
    "dist/",
    "build/",
    "vendor/",
  },
}
