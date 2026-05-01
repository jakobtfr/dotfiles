return {
	specs = {
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/mason-org/mason.nvim" },
		{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	},
	setup = function()
		require("mason").setup()
		require("mason-lspconfig").setup()
	end,
}
