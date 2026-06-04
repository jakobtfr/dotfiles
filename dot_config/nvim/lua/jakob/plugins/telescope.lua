return {
	specs = {
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	},
	setup = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")

		telescope.setup({
			pickers = {
				find_files = {
					no_ignore = true,
				},
			},
		})

		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
		vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "find git files" })
		vim.keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "live grep" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
		vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, { desc = "workspace symbols" })
	end,
}
