local languages = {
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
}

local function enable_highlighting()
	local group = vim.api.nvim_create_augroup("JakobTreesitterHighlight", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(event)
			local lang = vim.treesitter.language.get_lang(event.match)
			if lang == nil or not vim.tbl_contains(languages, lang) then
				return
			end

			pcall(vim.treesitter.start, event.buf, lang)
		end,
	})
end

return {
	specs = {
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	},
	before_add = function()
		vim.api.nvim_create_autocmd("PackChanged", {
			callback = function(event)
				if event.data.kind == "delete" or event.data.spec.name ~= "nvim-treesitter" then
					return
				end

				vim.schedule(function()
					pcall(vim.cmd.packadd, "nvim-treesitter")
					if vim.fn.exists(":TSUpdate") == 2 then
						pcall(vim.cmd.TSUpdate)
					elseif vim.fn.exists(":TSUpdateSync") == 2 then
						pcall(vim.cmd.TSUpdateSync)
					end
				end)
			end,
		})
	end,
	setup = function()
		local treesitter = require("nvim-treesitter")

		if type(treesitter.install) == "function" then
			treesitter.setup()
			if #vim.api.nvim_list_uis() > 0 then
				pcall(treesitter.install, languages)
			end
			enable_highlighting()
			return
		end

		-- Legacy master branch fallback. Markdown highlighting can crash on Neovim 0.12.
		require("nvim-treesitter.configs").setup({
			ensure_installed = languages,
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				disable = { "markdown", "markdown_inline" },
				additional_vim_regex_highlighting = false,
			},
		})
	end,
}
