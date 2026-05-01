return {
	specs = {
		{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	},
	setup = function()
		vim.cmd.colorscheme("rose-pine")
	end,
}
