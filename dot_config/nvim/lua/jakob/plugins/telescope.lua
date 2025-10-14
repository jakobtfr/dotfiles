return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		-- TODO: use remap
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
		vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "find git files" })
		vim.keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "live grep" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
	end,
}
