-- Build treesitter parsers after nvim-treesitter is installed or updated.
-- Must be registered before vim.pack.add.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		if event.data.spec.name == "nvim-treesitter" and event.data.kind ~= "delete" then
			vim.schedule(function()
				vim.cmd.packadd("nvim-treesitter")
				vim.cmd.TSUpdate()
			end)
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.0.0 - 2.0.0") },
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/tpope/vim-fugitive", version = "master" },
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false, load = true })

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update plugins" })

-- Colorscheme ----------------------------------------------------------------

require("rose-pine").setup({ styles = { transparency = true } })
vim.cmd.colorscheme("rose-pine")

-- Completion -----------------------------------------------------------------

require("blink.cmp").setup({
	keymap = { preset = "super-tab" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false } },
	sources = { default = { "lsp", "path", "buffer" } },
	fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Formatting -----------------------------------------------------------------

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_organize_imports", "ruff_format" },
		rust = { "rustfmt" },
		typescript = { "biome" },
		javascript = { "biome" },
	},
	format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
})

-- Git ------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- File explorer --------------------------------------------------------------

require("nvim-web-devicons").setup()
require("oil").setup({
	delete_to_trash = true,
	keymaps = {
		["<C-h>"] = false,
		["<C-l>"] = false,
		["<C-t>"] = false,
		["<C-c>"] = false,
		["<C-v>"] = { "actions.select", opts = { vertical = true }, mode = "n" },
		["<C-x>"] = { "actions.select", opts = { horizontal = true }, mode = "n" },
		["gy"] = { "actions.yank_entry", mode = "n" },
		["<C-p>"] = function()
			local oil_win = vim.api.nvim_get_current_win()
			local entry = require("oil").get_cursor_entry()
			local preview_win = require("oil.util").get_preview_win()
			if preview_win and entry and vim.w[preview_win].oil_entry_id == entry.id then
				vim.api.nvim_win_close(preview_win, true)
				return
			end

			require("oil").open_preview({ vertical = true, split = "belowright" }, function()
				if vim.api.nvim_win_is_valid(oil_win) then
					vim.api.nvim_win_set_width(oil_win, math.max(24, math.floor(vim.o.columns * 0.2)))
				end
			end)
		end,
	},
	float = { preview_split = "right" },
})
vim.keymap.set("n", "<leader>e", function()
	if vim.bo.filetype ~= "oil" then
		vim.cmd.Oil()
	end
end, { desc = "Open parent directory" })

-- Fuzzy finder ---------------------------------------------------------------

local builtin = require("telescope.builtin")
require("telescope").setup({
	pickers = { find_files = { no_ignore = true } },
})
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "find git files" })
vim.keymap.set("n", "<leader>fl", builtin.live_grep, { desc = "live grep" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, { desc = "workspace symbols" })

-- Pane navigation (tmux / herdr) ---------------------------------------------

-- Inside herdr (not tmux): move between Vim windows, then hand off to herdr at
-- the edge (its Ctrl-h/j/k/l binding forwards the key to Vim).
local in_herdr = vim.env.HERDR_ENV and not vim.env.TMUX
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, cmd in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
	vim.keymap.set("n", "<c-" .. key .. ">", function()
		if not in_herdr then
			vim.cmd("TmuxNavigate" .. cmd)
			return
		end
		local win = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(key)
		if vim.api.nvim_get_current_win() == win then
			local herdr = vim.env.HERDR_BIN_PATH or "herdr"
			vim.system({ herdr, "pane", "focus", "--pane", vim.env.HERDR_PANE_ID, "--direction", directions[key] })
		end
	end, { silent = true })
end
vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true })

-- Treesitter -----------------------------------------------------------------

local ts_languages = {
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
if #vim.api.nvim_list_uis() > 0 then
	require("nvim-treesitter").install(ts_languages)
end
-- Highlight with treesitter wherever a parser is available.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		pcall(vim.treesitter.start, event.buf)
	end,
})
