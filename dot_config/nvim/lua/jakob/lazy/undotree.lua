return {
	"mbbill/undotree",
	branch = "master",
	config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
	end,
}
