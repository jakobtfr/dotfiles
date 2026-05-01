if vim.pack == nil then
	error("vim.pack requires Neovim 0.12 or newer")
end

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
