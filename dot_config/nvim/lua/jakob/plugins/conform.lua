return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort" },
				rust = { "rustfmt" },
				typescript = { "biome" },
				javascript = { "biome" },
				java = { "checkstyle" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "never",
			},
		})
	end,
}
