return {
	specs = {
		{ src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
	},
	setup = function()
		require("ibl").setup({
			indent = {
				char = "│",
			},
		})
	end,
}
