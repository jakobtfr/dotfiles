return {
	specs = {
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
	},
	before_add = function()
		vim.api.nvim_create_autocmd("PackChanged", {
			callback = function(event)
				if event.data.kind == "delete" or event.data.spec.name ~= "nvim-treesitter" then
					return
				end

				vim.schedule(function()
					pcall(vim.cmd.packadd, "nvim-treesitter")
					if vim.fn.exists(":TSUpdateSync") == 2 then
						pcall(vim.cmd.TSUpdateSync)
					end
				end)
			end,
		})
	end,
	setup = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"python",
				"javascript",
				"typescript",
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"markdown",
				"markdown_inline",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
