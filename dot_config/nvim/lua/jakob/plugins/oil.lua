return {
	specs = {
		{ src = "https://github.com/nvim-mini/mini.icons" },
		{ src = "https://github.com/stevearc/oil.nvim" },
	},
	setup = function()
		require("mini.icons").setup()
		require("oil").setup()
		vim.keymap.set("n", "<leader><space>", "<cmd>Oil<CR>", { desc = "Open parent directory" })
	end,
}
