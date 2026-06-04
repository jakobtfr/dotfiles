return {
	specs = {
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
		{ src = "https://github.com/stevearc/oil.nvim" },
	},
	setup = function()
		require("nvim-web-devicons").setup()
		require("oil").setup()
		vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open parent directory" })
	end,
}
