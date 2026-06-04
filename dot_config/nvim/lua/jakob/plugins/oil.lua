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
					local entry = require("oil").get_cursor_entry()
					local preview_win = require("oil.util").get_preview_win()
					if preview_win and entry and vim.w[preview_win].oil_entry_id == entry.id then
						vim.api.nvim_win_close(preview_win, true)
						return
					end

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
		vim.keymap.set("n", "<leader>e", function()
			if vim.bo.filetype == "oil" then
				return
			end

			vim.cmd.Oil()
		end, { desc = "Open parent directory" })
	end,
}
