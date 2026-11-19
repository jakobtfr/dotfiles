-- Server configs come from nvim-lspconfig; binaries from Brewfile / packages-arch.txt.

-- pyright owns hover/type info; ruff is diagnostics + formatting only.
vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})

vim.lsp.enable({
	"clangd",
	"pyright",
	"ruff",
	"rust_analyzer",
	"texlab",
	"ts_ls",
})

-- Mapped unconditionally, mirroring Neovim's built-in gr* LSP defaults.
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "vim.lsp.buf.definition()" })
vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { desc = "vim.lsp.buf.declaration()" })
