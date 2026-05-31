local M = {}

local stamp_path = vim.fs.joinpath(vim.fn.stdpath("state"), "pack-auto-update")
local running = false

local function read_stamp()
	local ok, lines = pcall(vim.fn.readfile, stamp_path)
	if not ok or lines[1] == nil then
		return 0
	end

	return tonumber(lines[1]) or 0
end

local function write_stamp()
	vim.fn.mkdir(vim.fn.fnamemodify(stamp_path, ":h"), "p")
	vim.fn.writefile({ tostring(os.time()) }, stamp_path)
end

local function try_write_stamp()
	pcall(write_stamp)
end

local function auto_updates_enabled()
	if vim.env.NVIM_PACK_AUTO_UPDATE == "0" then
		return false
	end

	return vim.g.pack_auto_update ~= false
end

local function update_due()
	local interval = tonumber(vim.g.pack_auto_update_interval) or (24 * 60 * 60)
	return os.time() - read_stamp() >= interval
end

local function snapshot_revs()
	local revs = {}
	local ok, plugins = pcall(vim.pack.get, nil, { info = false })
	if not ok then
		return revs
	end

	for _, plugin in ipairs(plugins) do
		revs[plugin.spec.name] = plugin.rev
	end

	return revs
end

local function changed_plugins(before, after)
	local changed = {}
	for name, rev in pairs(after) do
		if before[name] ~= nil and before[name] ~= rev then
			table.insert(changed, name)
		end
	end
	table.sort(changed)
	return changed
end

function M.update()
	if running then
		return
	end

	running = true
	vim.notify("Updating Neovim plugins...", vim.log.levels.INFO, { title = "vim.pack" })

	local before = snapshot_revs()
	local ok, err = pcall(vim.pack.update, nil, { force = true })
	local after = snapshot_revs()
	running = false
	try_write_stamp()

	if not ok then
		vim.notify(("Plugin update failed: %s"):format(err), vim.log.levels.ERROR, { title = "vim.pack" })
		return
	end

	local changed = changed_plugins(before, after)
	if #changed == 0 then
		vim.notify("Plugins are up to date.", vim.log.levels.INFO, { title = "vim.pack" })
	else
		vim.notify(
			("Updated %d plugin%s: %s"):format(#changed, #changed == 1 and "" or "s", table.concat(changed, ", ")),
			vim.log.levels.INFO,
			{ title = "vim.pack" }
		)
	end
end

function M.setup()
	pcall(vim.api.nvim_del_user_command, "PackAutoUpdate")
	vim.api.nvim_create_user_command("PackAutoUpdate", M.update, {
		desc = "Update vim.pack plugins without confirmation",
	})

	if not auto_updates_enabled() then
		return
	end

	local group = vim.api.nvim_create_augroup("JakobPackAutoUpdate", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		once = true,
		callback = function()
			if #vim.api.nvim_list_uis() == 0 or not update_due() then
				return
			end

			local delay = tonumber(vim.g.pack_auto_update_delay_ms) or 3000
			vim.defer_fn(M.update, delay)
		end,
		desc = "Automatically update vim.pack plugins",
	})
end

return M
