vim.api.nvim_create_augroup("AutoReloadFile", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		vim.cmd("checktime")
	end,
	desc = "Check for file changes when entering buffer or gaining focus",
})
