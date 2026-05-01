return {
	specs = {
		{ src = "https://github.com/mbbill/undotree", version = "master" },
	},
	setup = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
	end,
}
