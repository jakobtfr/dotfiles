vim.opt.nu = true
vim.opt.relativenumber = true

-- tab size
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wrap = false -- default off (code); prose filetypes turn it on below
vim.opt.linebreak = true -- when wrap is on, break at word boundaries, not mid-word
vim.opt.breakindent = true -- wrapped lines keep the line's indent

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit", "tex", "typst", "help" },
	callback = function()
		vim.opt_local.wrap = true
	end,
})

-- move by visual line unless a count is given, so wrapped prose scrolls row-by-row
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.hlsearch = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 250

vim.opt.tw = 80
vim.opt.colorcolumn = "+1"

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
})

vim.o.winborder = "rounded"

vim.opt.laststatus = 3
