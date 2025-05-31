-- Set leader key (should match core.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure clipboard settings are correct
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard by default

-- Project Search (leader + ps) - Search in all files
vim.keymap.set("n", "<leader>ps", function()
    require('telescope.builtin').live_grep({
        cwd = vim.loop.cwd(),
        hidden = true
    })
end, { desc = "Project Search (grep)" })

-- Quick File Search (leader + pf) - Find files
vim.keymap.set("n", "<leader>pf", function()
    require('telescope.builtin').find_files({
        cwd = vim.loop.cwd(),
        hidden = true
    })
end, { desc = "Project Files" })

-- Git Files (leader + gf) - Find in git files
vim.keymap.set("n", "<leader>gf", function()
    require('telescope.builtin').git_files()
end, { desc = "Git Files" })

-- Window management
vim.keymap.set("n", "<leader>sv", vim.cmd.vsplit, { desc = "Split Vertically" })
vim.keymap.set("n", "<leader>sh", vim.cmd.split, { desc = "Split Horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make Splits Equal" })
vim.keymap.set("n", "<leader>sx", vim.cmd.close, { desc = "Close Split" })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open Diagnostic Float" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Git mappings
vim.keymap.set("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Git Blame" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview Git Hunk" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Git Hunk" })

-- LSP mappings (only active when LSP is attached)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code Actions" })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename Symbol" })
        vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = ev.buf, desc = "Format Document" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to Definition" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "Find References" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Show Hover Documentation" })
    end,
}) 

-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }


-- Netrw with better buffer handling
vim.keymap.set("n", "<leader>pv", function()
    -- Clear jumplist before opening netrw
    vim.cmd('clearjumps')
    -- Open netrw in the current window
    vim.cmd('Ex')
end, { noremap = true, silent = true })

-- Basic keymaps that don't depend on plugins
map("n", "<leader>ps", function()
    require('telescope.builtin').live_grep({ cwd = vim.fn.stdpath("config") })
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
