local servers = {
	"clangd",
	"cmake",
	"jdtls",
	"rust_analyzer",
}

if #servers > 0 then
	vim.lsp.enable(servers)
end

-- Mapped unconditionally, mirroring Neovim's built-in gr* LSP defaults.
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
