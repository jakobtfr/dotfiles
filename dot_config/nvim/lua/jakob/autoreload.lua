-- Set autoread option globally
vim.opt.autoread = true

-- Create augroup for file reload management
vim.api.nvim_create_augroup("AutoReloadFile", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		vim.cmd("checktime")
	end,
	desc = "Check for file changes when entering buffer or gaining focus",
})

vim.api.nvim_create_autocmd("FileChangedShell", {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		if vim.bo[bufnr].modified then
			vim.notify(
				"⚠️ File changed on disk but you have unsaved changes! ⚠️\nUse :e! to reload from disk (discards changes)",
				vim.log.levels.WARN,
				{
					title = "File Change Conflict",
					timeout = 0,
					on_open = function(win)
						vim.api.nvim_win_set_option(win, "winhl", "Normal:WarningMsg")
					end,
				}
			)
		end
	end,
	desc = "Notify when file changed externally with unsaved changed",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = "AutoReloadFile",
	pattern = "*",
	callback = function()
		vim.notify("File changed on disk and has been reloaded.", vim.log.levels.INFO, {
			title = "File Reloaded",
			timeout = 3000,
		})
	end,
	desc = "Notify when file has been automatically reloaded",
})

-- Create a timer to periodically check for file changes (every 3 seconds)
local check_timer = vim.loop.new_timer()
check_timer:start(
	0,
	3000,
	vim.schedule_wrap(function()
		if vim.api.nvim_get_mode().mode ~= "c" then
			vim.cmd("checktime")
		end
	end)
)
