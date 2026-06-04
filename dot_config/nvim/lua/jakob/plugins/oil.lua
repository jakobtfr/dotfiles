return {
	specs = {
		{ src = "https://github.com/stevearc/oil.nvim" },
	},
	setup = function()
		require("oil").setup()
		vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
	end,
}
