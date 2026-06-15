local servers = {
	"basedpyright",
	"clangd",
	"cmake",
	"jdtls",
	"ruff",
	"rust_analyzer",
}

-- basedpyright owns hover/type info; ruff is diagnostics + formatting only.
vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})

if #servers > 0 then
	vim.lsp.enable(servers)
end

-- Mapped unconditionally, mirroring Neovim's built-in gr* LSP defaults.
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
