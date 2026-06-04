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
				["<C-p>"] = function()
					local oil_win = vim.api.nvim_get_current_win()
					require("oil").open_preview({ vertical = true, split = "belowright" }, function()
						if vim.api.nvim_win_is_valid(oil_win) then
							vim.api.nvim_win_set_width(oil_win, math.max(24, math.floor(vim.o.columns * 0.2)))
						end
					end)
				end,
			},
			float = {
				preview_split = "right",
			},
		})
		vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Open parent directory" })
	end,
}
