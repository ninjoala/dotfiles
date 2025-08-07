-- Set leader key (should match core.lua)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure clipboard settings are correct
vim.opt.clipboard = "unnamedplus" -- Use system clipboard by default

-- Quick save and quit mappings
-- 'e' for 'edit/etched' (saving etches your edits to disk)
-- 'r' for 'return' (quit returns you to the terminal)
vim.keymap.set("n", "<leader>e", ":w<CR>", { desc = "Save file (etch changes)" })
vim.keymap.set("n", "<leader>r", ":q<CR>", { desc = "Quit (return to terminal)" })
vim.keymap.set("n", "<leader>E", ":wq<CR>", { desc = "Save and quit (etch and return)" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted code down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted code up" })

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", '"_dp', { desc = "paste and delete highlighted, preserve y register" })

-- Reload config
vim.keymap.set("n", "<leader>so", ":source $MYVIMRC<CR>", { desc = "Source (reload) config" })

-- Quick File Search (leader + pf) - Find files
vim.keymap.set("n", "<leader>pf", function()
	require("telescope.builtin").find_files({
		cwd = vim.loop.cwd(),
		hidden = true,
	})
end, { desc = "Project Files" })

-- Git Files (leader + gf) - Find in git files
vim.keymap.set("n", "<leader>gf", function()
	require("telescope.builtin").git_files()
end, { desc = "Git Files" })

-- Project Search (leader + ps) - Live grep respecting .gitignore
vim.keymap.set("n", "<leader>ps", function()
	require("telescope.builtin").live_grep({
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
	})
end, { desc = "Project Search (live grep)" })

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

-- Keymaps
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Oil file explorer
vim.keymap.set("n", "<leader>pv", function()
	require("oil").open()
end, { noremap = true, silent = true, desc = "Open file explorer" })

-- Clipboard keymaps for tmux integration
-- Yank to system clipboard
map("v", "<leader>y", '"+y', opts)
map("n", "<leader>yy", '"+yy', opts)
-- Delete to black hole register (won't affect clipboard)
map("n", "dd", '"_dd', opts)
map("v", "d", '"_d', opts)

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlighting" })

-- Load plugin-specific keymaps after plugins are initialized
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	callback = function()
		-- Harpoon setup
		local ok, harpoon = pcall(require, "harpoon")
		if ok then
			harpoon:setup()

			-- Harpoon keymaps
			map("n", "<leader>a", function()
				harpoon:list():add()
			end, opts)
			map("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, opts)

			-- Navigate to files
			map("n", "<C-h>", function()
				harpoon:list():select(1)
			end, opts)
			map("n", "<C-j>", function()
				harpoon:list():select(2)
			end, opts)
			map("n", "<C-k>", function()
				harpoon:list():select(3)
			end, opts)
			map("n", "<C-l>", function()
				harpoon:list():select(4)
			end, opts)

			-- Toggle previous & next buffers stored within Harpoon list
			map("n", "<C-S-P>", function()
				harpoon:list():prev()
			end, opts)
			map("n", "<C-S-N>", function()
				harpoon:list():next()
			end, opts)
		end
	end,
})

-- Global LSP keymaps (single source of truth for all LSP servers)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local opts = { buffer = bufnr, noremap = true, silent = true }

		-- Prevent duplicate keybindings if already set for this buffer
		if vim.b[bufnr].lsp_keymaps_set then
			return
		end
		vim.b[bufnr].lsp_keymaps_set = true

		-- LSP navigation with Telescope
		vim.keymap.set("n", "<leader>fd", require("telescope.builtin").lsp_definitions, opts)
		vim.keymap.set("n", "<leader>fD", require("telescope.builtin").lsp_type_definitions, opts)
		vim.keymap.set("n", "<leader>fi", require("telescope.builtin").lsp_implementations, opts)
		vim.keymap.set(
			"n",
			"<leader>fr",
			"<cmd>Telescope lsp_references<cr>",
			{ buffer = bufnr, desc = "Telescope LSP References" }
		)
		vim.keymap.set("n", "<leader>ws", require("telescope.builtin").lsp_workspace_symbols, opts)
		vim.keymap.set("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)

		-- LSP actions
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ lsp_fallback = true })
		end, opts)
		vim.keymap.set("v", "<leader>f", function()
			require("conform").format({ lsp_fallback = true })
		end, opts)
		vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

		-- Diagnostics with Telescope
		vim.keymap.set("n", "<leader>d", require("telescope.builtin").diagnostics, opts)
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	end,
})

-- Window navigation mappings
map("n", "<leader>h", "<C-w>h", opts)
map("n", "<leader>j", "<C-w>j", opts)
map("n", "<leader>k", "<C-w>k", opts)
map("n", "<leader>l", "<C-w>l", opts)

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Rename word whole file" }
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file you're on executable" })
