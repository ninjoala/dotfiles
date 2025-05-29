-- Set leader key (should match core.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

-- Common VSCode-like mappings
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open File Explorer" })
vim.keymap.set("n", "<leader>w", vim.cmd.write, { desc = "Save File" })
vim.keymap.set("n", "<leader>q", vim.cmd.quit, { desc = "Quit" })
vim.keymap.set("n", "<leader>h", vim.cmd.nohl, { desc = "Clear Search Highlights" })

-- Buffer navigation (similar to VSCode tabs)
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext, { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", vim.cmd.bprevious, { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete, { desc = "Delete Buffer" })

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