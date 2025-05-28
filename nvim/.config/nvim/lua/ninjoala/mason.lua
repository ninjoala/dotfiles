local M = {}

M.ensure_installed = {
  "lua-language-server",
  "roslyn",
  "xmlformatter",
  "stylua",
  "bicep-lsp",
  "html-lsp",
  "css-lsp",
  "csharpier",
  "prettier",
  "json-lsp"
}

function M.setup()
  local registry = require("mason-registry")
  for _, pkg_name in ipairs(M.ensure_installed) do
    if not registry.is_installed(pkg_name) then
      vim.cmd("MasonInstall " .. pkg_name)
    end
  end
end

return M 