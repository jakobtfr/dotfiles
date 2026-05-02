if vim.pack == nil then
	error("vim.pack requires Neovim 0.12 or newer")
end

local function prune_lazy_runtimepath()
	local lazy_root = vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy")
	local runtimepath = {}

	for _, path in ipairs(vim.opt.runtimepath:get()) do
		path = vim.fs.normalize(path)
		if path ~= lazy_root and not vim.startswith(path, lazy_root .. "/") then
			table.insert(runtimepath, path)
		end
	end

	vim.opt.runtimepath = runtimepath
end

prune_lazy_runtimepath()

local plugins = {}
local specs = {}

for _, module_name in ipairs(require("jakob.plugins")) do
	local plugin = require(module_name)
	table.insert(plugins, plugin)

	if plugin.before_add ~= nil then
		plugin.before_add()
	end

	for _, spec in ipairs(plugin.specs or {}) do
		table.insert(specs, spec)
	end
end

vim.pack.add(specs, { confirm = false, load = true })

for _, plugin in ipairs(plugins) do
	if plugin.setup ~= nil then
		plugin.setup()
	end
end
