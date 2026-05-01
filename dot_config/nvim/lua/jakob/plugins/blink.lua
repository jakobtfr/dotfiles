return {
	specs = {
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.0.0 - 2.0.0") },
	},
	setup = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "enter",
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = {
					auto_show = false,
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
		})
	end,
}
