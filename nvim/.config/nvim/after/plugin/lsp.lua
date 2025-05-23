require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "csharp_ls" }
})

require("lspconfig").lua_ls.setup {}
require("lspconfig").csharp_ls.setup {}
