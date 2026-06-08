vim.opt.autoread = true

vim.api.nvim_create_augroup("AutoReloadFile", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" }, {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
	desc = "Check for external file changes on idle, buffer enter, or focus",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		vim.notify("File changed on disk, buffer reloaded", vim.log.levels.INFO)
	end,
	desc = "Notify when a buffer is reloaded after an external change",
})
