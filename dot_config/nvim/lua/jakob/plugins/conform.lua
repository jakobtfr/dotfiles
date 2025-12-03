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
				-- java = { "google-java-format" },
			},
			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
		})
	end,
}
