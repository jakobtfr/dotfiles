local XCODE_DEV = "/Applications/Xcode.app/Contents/Developer"
local XCODE_TC = XCODE_DEV .. "/Toolchains/XcodeDefault.xctoolchain"

vim.lsp.config("sourcekit", {
	cmd = { XCODE_TC .. "/usr/bin/sourcekit-lsp" }, -- Xcode toolchain override
	filetypes = { "swift" },
	single_file_support = true,
	root_markers = { ".git/", "Package.swift" },
	capabilities = {
		workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
	},
})
vim.lsp.config("biome", {
	root_markers = { "biome.json" },
})
vim.lsp.enable("sourcekit")
