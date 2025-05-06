local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- Basic setup
telescope.setup({
    defaults = {
        find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob=!.git/*"
        },
        path_display = { "truncate" },
        file_ignore_patterns = {
            "^.git/",
            "^node_modules/",
        },
    },
})

-- Keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Debug function to check if telescope is working
local function check_telescope()
    print("Telescope is loaded")
    print("Builtin functions available:", vim.inspect(builtin))
end 
