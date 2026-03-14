return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			on_attach = function(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end
				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.del("n", "<C-k>", { buffer = bufnr })
				vim.keymap.set("n", "i", api.node.show_info_popup, opts("Info"))
				vim.keymap.set("n", "<C-r>", api.tree.change_root_to_node, opts("CD"))
			end,
		})
	end,
}
