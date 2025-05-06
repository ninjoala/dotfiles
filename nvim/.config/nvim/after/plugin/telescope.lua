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

-- Debug function
local function debug_find_files()
    local cwd = vim.fn.getcwd()
    print("Current working directory:", cwd)
    print("Running find_files...")
    builtin.find_files({
        find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob=!.git/*"
        },
        cwd = cwd,
    })
end

-- Keymaps
vim.keymap.set('n', '<leader>pf', debug_find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Debug function to check if telescope is working
local function check_telescope()
    print("Telescope is loaded")
    print("Builtin functions available:", vim.inspect(builtin))
end 
