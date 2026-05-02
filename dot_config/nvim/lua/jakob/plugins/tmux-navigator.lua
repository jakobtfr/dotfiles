return {
	specs = {
		{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	},
	setup = function()
		local opts = { silent = true }

		vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
		vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", opts)
		vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", opts)
		vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", opts)
		vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", opts)
	end,
}
