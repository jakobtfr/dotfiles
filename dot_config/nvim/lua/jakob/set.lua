vim.opt.nu = true
vim.opt.relativenumber = true

-- tab size
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wrap = false

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
	virtual_text = false,
	virtual_lines = false,
})

vim.o.winborder = "rounded"

vim.opt.laststatus = 3
