return {
	specs = {
		{ src = "https://github.com/tpope/vim-fugitive", version = "master" },
	},
	setup = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
	end,
}
