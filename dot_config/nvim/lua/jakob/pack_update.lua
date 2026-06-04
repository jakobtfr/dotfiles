local M = {}

function M.setup()
	pcall(vim.api.nvim_del_user_command, "PackUpdate")
	vim.api.nvim_create_user_command("PackUpdate", function()
		vim.pack.update()
	end, {
		desc = "Update vim.pack plugins",
	})
end

return M
