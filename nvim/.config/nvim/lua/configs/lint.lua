local lint = require("lint")

lint.linters_by_ft = {
	yaml = { "yamllint" },
	lua = { "luacheck" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {

	callback = function()
		lint.try_lint()
	end,
})
