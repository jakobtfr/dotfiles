if vim.pack == nil then
	error("vim.pack requires Neovim 0.12 or newer")
end

local function gh(repo)
	return "https://github.com/" .. repo
end

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

vim.pack.add({
	{ src = gh("rose-pine/neovim"), name = "rose-pine" },

	{ src = gh("windwp/nvim-autopairs") },
	{ src = gh("rafamadriz/friendly-snippets") },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.0.0 - 2.0.0") },

	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("tpope/vim-fugitive"), version = "master" },
	{ src = gh("lukas-reineke/indent-blankline.nvim") },

	{ src = gh("nvim-tree/nvim-web-devicons") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("nvim-tree/nvim-tree.lua") },

	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("mason-org/mason-lspconfig.nvim") },

	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("nvim-telescope/telescope-ui-select.nvim") },
	{ src = gh("nvim-telescope/telescope.nvim"), version = "0.1.8" },

	{ src = gh("christoomey/vim-tmux-navigator") },
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "master" },
	{ src = gh("mbbill/undotree"), version = "master" },
	{ src = gh("folke/which-key.nvim") },
}, { confirm = false, load = true })

vim.cmd.colorscheme("rose-pine")

require("nvim-autopairs").setup()

require("blink.cmp").setup({
	keymap = {
		preset = "enter",
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = {
			auto_show = false,
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort" },
		rust = { "rustfmt" },
		typescript = { "biome" },
		javascript = { "biome" },
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

require("ibl").setup({
	indent = {
		char = "│",
	},
})

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
			refresh_time = 16,
			events = {
				"WinEnter",
				"BufEnter",
				"BufWritePost",
				"SessionLoadPost",
				"FileChangedShellPost",
				"VimResized",
				"Filetype",
				"CursorMoved",
				"CursorMovedI",
				"ModeChanged",
			},
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { "nvim-tree" },
})

require("mason").setup()
require("mason-lspconfig").setup()

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

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})

telescope.load_extension("ui-select")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "find git files" })
vim.keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "live grep" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>")
vim.keymap.set("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>")

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

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

require("which-key").setup()
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
