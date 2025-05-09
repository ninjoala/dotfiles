-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Telescope
map("n", "<leader>ps", function()
    require('telescope.builtin').live_grep()
end, opts)
