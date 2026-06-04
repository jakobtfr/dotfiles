return {
	specs = {
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
		{ src = "https://github.com/stevearc/oil.nvim" },
	},
	setup = function()
		require("nvim-web-devicons").setup()
		require("oil").setup({
			delete_to_trash = true,
			keymaps = {
				["<C-h>"] = false,
				["<C-l>"] = false,
				["<C-t>"] = false,
				["<C-c>"] = false,
			},
			float = {
				preview_split = "right",
			},
		})
		vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open parent directory" })
	end,
}
