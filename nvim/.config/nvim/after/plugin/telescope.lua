local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- Basic setup
telescope.setup({
    defaults = {
        -- File finding settings
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
        
        -- Layout configuration (NvChad/Lazy.nvim style)
        layout_strategy = 'horizontal',
        layout_config = {
            horizontal = {
                height = 0.99,
                preview_cutoff = 120,
                prompt_position = "top",
                width = 0.99,
                preview_width = 0.6,
            },
        },

        -- Appearance
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        scroll_strategy = "cycle",
        
        -- Better looking results
        results_title = false,
        borderchars = {
            prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            results = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        },
    },
    pickers = {
        find_files = {
            previewer = true,
            hidden = true,
        },
        live_grep = {
            previewer = true,
        },
        buffers = {
            previewer = true,
        },
    },
})

-- Load fzf extension if available
pcall(telescope.load_extension, "fzf")

-- Debug function to ensure it works
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
