-- This file is now simplified since mason-lspconfig handles LSP server installation
-- Only need to handle formatters, linters, and other tools

local M = {}

-- Non-LSP tools that need manual installation
M.ensure_installed = {
	"stylua", -- Lua formatter
	"prettier", -- JS/TS/HTML/CSS formatter
}

function M.setup()
	-- Avoid starting asynchronous package installs during headless maintenance jobs.
	if #vim.api.nvim_list_uis() == 0 then
		return
	end

	-- Mason-lspconfig now handles LSP servers automatically
	-- Only install formatters and other tools manually if needed
	local registry = require("mason-registry")
	for _, pkg_name in ipairs(M.ensure_installed) do
		if not registry.is_installed(pkg_name) then
			vim.notify("Installing " .. pkg_name .. "...", vim.log.levels.INFO)
			vim.cmd("MasonInstall " .. pkg_name)
		end
	end
end

return M
