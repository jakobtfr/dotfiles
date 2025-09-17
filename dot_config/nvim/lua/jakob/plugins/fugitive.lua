return {
	"tpope/vim-fugitive",
	branch = "master",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git);
	end
}
