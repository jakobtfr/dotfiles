local directions = { h = "left", j = "down", k = "up", l = "right" }

-- Outside tmux but inside Herdr: move between windows, then hand off to Herdr
-- at the edge (its Ctrl-h/j/k/l binding forwards the key to Vim).
local function herdr_navigate(key)
	local win = vim.api.nvim_get_current_win()
	vim.cmd.wincmd(key)
	if vim.api.nvim_get_current_win() == win then
		local herdr = vim.env.HERDR_BIN_PATH or "herdr"
		local pane = vim.env.HERDR_PANE_ID
		vim.system({ herdr, "pane", "focus", "--pane", pane, "--direction", directions[key] })
	end
end

return {
	specs = {
		{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	},
	setup = function()
		local opts = { silent = true }
		local in_herdr = vim.env.HERDR_ENV and not vim.env.TMUX

		for key, cmd in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
			vim.keymap.set("n", "<c-" .. key .. ">", function()
				if in_herdr then
					herdr_navigate(key)
				else
					vim.cmd("TmuxNavigate" .. cmd)
				end
			end, opts)
		end
		vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", opts)
	end,
}
