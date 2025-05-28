-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure clipboard settings are correct
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard by default

-- Netrw with better buffer handling
vim.keymap.set("n", "<leader>pv", function()
    -- Clear jumplist before opening netrw
    vim.cmd('clearjumps')
    -- Open netrw in the current window
    vim.cmd('Ex')
end, { noremap = true, silent = true })

-- Basic keymaps that don't depend on plugins
map("n", "<leader>ps", function()
    require('telescope.builtin').live_grep()
end, opts)

-- Clipboard keymaps for tmux integration
-- Yank to system clipboard
map("n", "<leader>y", '"+y', opts)
map("v", "<leader>y", '"+y', opts)
map("n", "<leader>yy", '"+yy', opts)
-- Paste from system clipboard
map("n", "<leader>p", '"+p', opts)
map("n", "<leader>P", '"+P', opts)
map("v", "<leader>p", '"+p', opts)
map("v", "<leader>P", '"+P', opts)
-- Delete to black hole register (won't affect clipboard)
map("n", "dd", '"_dd', opts)
map("v", "d", '"_d', opts)

-- Load plugin-specific keymaps after plugins are initialized
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLoad",
    callback = function()
        -- Harpoon setup
        local ok, harpoon = pcall(require, "harpoon")
        if ok then
            harpoon:setup()

            -- Harpoon keymaps
            map("n", "<leader>a", function() harpoon:list():add() end, opts)
            map("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, opts)

            -- Navigate to files
            map("n", "<C-h>", function() harpoon:list():select(1) end, opts)
            map("n", "<C-j>", function() harpoon:list():select(2) end, opts)
            map("n", "<C-k>", function() harpoon:list():select(3) end, opts)
            map("n", "<C-l>", function() harpoon:list():select(4) end, opts)

            -- Toggle previous & next buffers stored within Harpoon list
            map("n", "<C-S-P>", function() harpoon:list():prev() end, opts)
            map("n", "<C-S-N>", function() harpoon:list():next() end, opts)
        end
    end,
})

-- Global LSP keymaps (single source of truth for all LSP servers)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, noremap = true, silent = true }
    
    -- LSP navigation
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    
    -- LSP actions
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
    
    -- Diagnostics
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    
    -- Workspace
    vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
  end,
})

-- Window navigation mappings
map('n', '<leader>h', '<C-w>h', opts)
map('n', '<leader>j', '<C-w>j', opts)
map('n', '<leader>k', '<C-w>k', opts)
map('n', '<leader>l', '<C-w>l', opts)
