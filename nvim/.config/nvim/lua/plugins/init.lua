return {
	-- Theme
	{
		"Mofiqul/vscode.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode").setup({
				-- Enable transparent background
				transparent = true,
				-- Enable italic comments
				italic_comments = true,
				-- Disable nvim-tree background color
				disable_nvimtree_bg = true,
				-- Override colors (optional)
				color_overrides = {
					vscLineNumber = "#FFFFFF",
				},
			})
			-- Load the colorscheme
			vim.cmd.colorscheme("vscode")
		end,
	},

	-- Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Add file to Harpoon" })
			vim.keymap.set("n", "<C-e>", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon menu" })
			for index, lhs in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
				vim.keymap.set("n", lhs, function()
					harpoon:list():select(index)
				end, { desc = "Harpoon file " .. index })
			end
			vim.keymap.set("n", "<C-S-P>", function()
				harpoon:list():prev()
			end, { desc = "Previous Harpoon file" })
			vim.keymap.set("n", "<C-S-N>", function()
				harpoon:list():next()
			end, { desc = "Next Harpoon file" })
		end,
	},

	-- Mason (LSP installer)
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		lazy = false,
		priority = 900, -- Load right after theme but before other plugins
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "rounded",
				width = 0.8,
				height = 0.8,
			},
			max_concurrent_installers = 4,
		},
		config = function(_, opts)
			require("mason").setup(opts)
			require("ninjoala.mason").setup()
		end,
	},

	-- Mason-LSPConfig bridge
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "lua_ls", "pyright", "ts_ls", "html", "cssls", "jsonls" },
			automatic_enable = true,
		},
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Simple diagnostic config
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
			})

			-- Setup all servers with default config
			local servers = { "lua_ls", "pyright", "html", "cssls", "jsonls", "ts_ls" }
			for _, server in ipairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
				})
			end
		end,
	},

	-- Autocompletion (simplified, removed lsp-zero dependency)
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp", priority = 1000 },
					{ name = "luasnip", priority = 750 },
					{ name = "buffer", priority = 500 },
				}),
				formatting = {
					format = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
						})[entry.source.name]
						return vim_item
					end,
				},
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
			"nvim-treesitter/nvim-treesitter-context",
		},
		config = function()
			local languages = {
				"vim",
				"lua",
				"vimdoc",
				"query",
				"html",
				"css",
				"javascript",
				"typescript",
				"c",
				"c_sharp",
				"python",
				"json",
				"bicep",
			}
			local filetypes = {
				"vim",
				"lua",
				"help",
				"query",
				"html",
				"css",
				"javascript",
				"typescript",
				"c",
				"cs",
				"python",
				"json",
				"bicep",
			}
			local treesitter = require("nvim-treesitter")
			treesitter.setup()
			if #vim.api.nvim_list_uis() > 0 then
				treesitter.install(languages)
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function(args)
					vim.treesitter.start(args.buf)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})
			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")
			local function map_select(lhs, capture)
				vim.keymap.set({ "x", "o" }, lhs, function()
					select.select_textobject(capture, "textobjects")
				end)
			end
			local function map_move(lhs, method, capture)
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					move[method](capture, "textobjects")
				end)
			end

			map_select("af", "@function.outer")
			map_select("if", "@function.inner")
			map_select("ac", "@class.outer")
			map_select("ic", "@class.inner")
			map_move("]m", "goto_next_start", "@function.outer")
			map_move("]]", "goto_next_start", "@class.outer")
			map_move("]M", "goto_next_end", "@function.outer")
			map_move("][", "goto_next_end", "@class.outer")
			map_move("[m", "goto_previous_start", "@function.outer")
			map_move("[[", "goto_previous_start", "@class.outer")
			map_move("[M", "goto_previous_end", "@function.outer")
			map_move("[]", "goto_previous_end", "@class.outer")

			-- Setup treesitter-context
			require("treesitter-context").setup({
				enable = true,
				max_lines = 4,
				trim_scope = "outer",
			})
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make", -- Simplified build command
			},
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--no-ignore",
					},
					file_ignore_patterns = { "node_modules", ".git/", "*.pyc" },
					path_display = { "truncate" },
					layout_config = {
						horizontal = { preview_width = 0.6 },
					},
					set_env = {
						["COLORTERM"] = "truecolor",
					},
				},
				pickers = {
					find_files = { theme = "dropdown" },
					live_grep = { theme = "dropdown" },
					git_status = {
						previewer = require("telescope.previewers").new_termopen_previewer({
							get_command = function(entry)
								if entry.status == "??" or entry.status == "A " then
									return { "cat", entry.path }
								end
								return {
									"git",
									"-c",
									"color.diff=always",
									"-c",
									"color.ui=always",
									"-c",
									"color.status=always",
									"diff",
									"--no-color-moved",
									"--color=always",
									entry.path,
								}
							end,
						}),
						git_icons = {
							added = "+",
							changed = "~",
							copied = ">",
							deleted = "-",
							renamed = "➜",
							unmerged = "‡",
							untracked = "?",
						},
					},
				},
			})
			pcall(telescope.load_extension, "fzf")
		end,
	},

	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			-- Add checktime keybinding
			vim.keymap.set("n", "<leader>ct", "<cmd>checktime<CR>", { desc = "Check for file changes" })

			require("gitsigns").setup({
				attach_to_untracked = true,
				word_diff = true,
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				on_attach = function(bufnr)
					local gs = require("gitsigns")
					local map = function(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
					end

					-- Navigation
					map("n", "]h", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
							return
						end
						gs.nav_hunk("next")
					end, "Next git hunk")

					map("n", "[h", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
							return
						end
						gs.nav_hunk("prev")
					end, "Previous git hunk")

					-- Hunk review and staging
					map("n", "<leader>hp", gs.preview_hunk_inline, "Preview git hunk inline")
					map("n", "<leader>hb", function()
						gs.blame_line({ full = true })
					end, "Blame current line")
					map("n", "<leader>hd", gs.diffthis, "Diff file against index")
					map("n", "<leader>hD", function()
						gs.diffthis("~")
					end, "Diff file against HEAD")
					map({ "n", "x" }, "<leader>hs", gs.stage_hunk, "Stage git hunk")
					map("n", "<leader>hu", gs.undo_stage_hunk, "Undo staged hunk")
					map({ "n", "x" }, "<leader>hr", gs.reset_hunk, "Reset git hunk")
					map({ "o", "x" }, "ih", gs.select_hunk, "Select git hunk")

					-- View hunks
					map("n", "<leader>gL", function()
						gs.setqflist("all")
						vim.defer_fn(function()
							vim.cmd("cclose") -- Close the quickfix window if it's open
							require("telescope.builtin").quickfix({
								theme = "dropdown",
							})
						end, 100)
					end, "List repository hunks")
				end,
			})
		end,
	},

	-- Full repository and PR-style diffs
	{
		"esmuellert/codediff.nvim",
		cmd = "CodeDiff",
		keys = {
			{ "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Review working tree" },
			{
				"<leader>gD",
				function()
					local candidates = { "origin/HEAD", "origin/main", "origin/master", "main", "master" }
					for _, base in ipairs(candidates) do
						local result = vim.system({ "git", "rev-parse", "--verify", "--quiet", base }):wait()
						if result.code == 0 then
							vim.cmd("CodeDiff " .. base .. "...HEAD")
							return
						end
					end
					vim.notify("Could not find a default branch to review against", vim.log.levels.ERROR)
				end,
				desc = "Review branch against default branch",
			},
			{ "<leader>gF", "<cmd>CodeDiff history %<cr>", desc = "Current file history" },
			{ "<leader>gH", "<cmd>CodeDiff history<cr>", desc = "Repository history" },
		},
	},

	-- Status line (properly configured)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					component_separators = "|",
					section_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- File explorer
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				columns = { "icon", "permissions", "size", "mtime" },
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-s>"] = "actions.select_vsplit",
					["<C-h>"] = "actions.select_split",
					["<C-t>"] = "actions.select_tab",
					["<C-p>"] = "actions.preview",
					["<C-c>"] = "actions.close",
					["<C-l>"] = "actions.refresh",
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = "actions.tcd",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
					["g\\"] = "actions.toggle_trash",
				},
				use_default_keymaps = true,
				view_options = {
					show_hidden = true,
					is_hidden_file = function(name, bufnr)
						return vim.startswith(name, ".")
					end,
					is_always_hidden = function(name, bufnr)
						return false
					end,
				},
			})
		end,
	},

	-- Code formatter
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					json = { "prettier" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})
		end,
	},

	-- Targets.vim - Additional text objects
	{
		"wellle/targets.vim",
	},

	-- Which-key for manual keymap display
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			local wk = require("which-key")
			wk.setup({
				-- Disable automatic triggers
				triggers = {
					{ "<auto>", mode = "nixsotc" }, -- Don't auto-trigger on space
				},
				-- Only show when manually triggered
				delay = 999999, -- Very long delay to effectively disable auto-show
			})

			-- Register key groups for better organization (new format)
			wk.add({
				{ "<leader>f", group = "find/lsp" },
				{ "<leader>g", group = "git" },
				{ "<leader>p", group = "project" },
				{ "<leader>s", group = "split" },
				{ "<leader>d", group = "diagnostics" },
				{ "<leader>w", group = "workspace" },
				{ "<leader>c", group = "code" },
				{ "<leader>h", group = "hunk/window" },
			})

			-- Manual trigger keymap
			vim.keymap.set("n", "<leader>?", function()
				wk.show()
			end, { desc = "Show keybindings" })
		end,
	},

	-- Magit-style Git status and operations
	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		keys = {
			{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
			{ "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Git commit" },
			{ "<leader>gb", "<cmd>Neogit branch<cr>", desc = "Git branches" },
			{ "<leader>gl", "<cmd>Neogit log<cr>", desc = "Git log" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"esmuellert/codediff.nvim",
		},
		opts = {
			integrations = { telescope = true, codediff = true },
			diff_viewer = "codediff",
		},
	},

	-- GitHub pull request review and inline comments
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		keys = {
			{ "<leader>go", "<cmd>Octo pr list<cr>", desc = "GitHub pull requests" },
			{ "<leader>gR", "<cmd>Octo review<cr>", desc = "Start GitHub PR review" },
			{ "<leader>gA", "<cmd>Octo review submit<cr>", desc = "Submit GitHub PR review" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			picker = "telescope",
			enable_builtin = true,
			suppress_missing_scope = { projects_v2 = true },
		},
	},
}
