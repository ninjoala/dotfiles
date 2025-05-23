-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure clipboard settings are correct
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard by default

vim.keymap.set("n", "<leader>pv", function() vim.cmd("Ex") end)

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
