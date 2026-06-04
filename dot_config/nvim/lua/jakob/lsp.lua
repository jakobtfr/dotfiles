local servers = {
	"clangd",
}

if #servers > 0 then
	vim.lsp.enable(servers)
end
