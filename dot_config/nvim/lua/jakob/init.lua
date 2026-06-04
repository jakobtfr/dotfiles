vim.g.mapleader = " "
require("jakob.set")
require("jakob.pack_init")
require("jakob.pack_update").setup()
require("jakob.remap")
require("jakob.lsp")
require("jakob.autoreload")
