-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Basic keymaps that don't depend on plugins
map("n", "<leader>ps", function()
    require('telescope.builtin').live_grep()
end, opts)

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
