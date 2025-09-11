return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false,
	priority = 1000,
	config = function()
		require("github-theme").setup({
			options = {
				styles = {
					comments = "italic",
					functions = "bold",
					keywords = "italic",
				},
				transparent = false,
				dim_inactive = true,
			},
		})
	end,
}
