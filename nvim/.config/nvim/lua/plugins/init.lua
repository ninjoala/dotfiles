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
	},

	-- Mason (LSP installer)
	{
		"williamboman/mason.nvim",
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
	},

	-- Mason-LSPConfig bridge
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "lua_ls", "csharp_ls", "pyright", "ts_ls", "html", "cssls", "jsonls" },
			automatic_installation = true,
		},
	},

	-- LSP Configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Simple diagnostic config
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
			})

			-- Setup all servers with default config
			local servers = { "lua_ls", "pyright", "html", "cssls", "jsonls", "ts_ls", "csharp_ls" }
			for _, server in ipairs(servers) do
				lspconfig[server].setup({
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

	-- Treesitter (properly configured)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-context",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"vim",
					"lua",
					"vimdoc",
					"html",
					"css",
					"javascript",
					"typescript",
					"c_sharp",
					"python",
					"json",
					"bicep",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
				},
			})

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
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					-- Navigation
					vim.keymap.set("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, buffer = bufnr })

					vim.keymap.set("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, buffer = bufnr })

					-- View hunks
					vim.keymap.set("n", "<leader>gL", function()
						gs.setqflist("all")
						vim.defer_fn(function()
							vim.cmd("cclose") -- Close the quickfix window if it's open
							require("telescope.builtin").quickfix({
								theme = "dropdown",
							})
						end, 100)
					end, { buffer = bufnr, desc = "List git hunks" })

					-- Preview hunk inline
					vim.keymap.set("n", "<leader>hl", gs.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
				end,
			})
		end,
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
					lsp_fallback = true,
				},
			})
		end,
	},

	-- Targets.vim - Additional text objects
	{
		"wellle/targets.vim",
	},

	-- Fugitive for Git commands
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		config = function()
			-- Add keymaps that integrate with telescope where possible
			vim.keymap.set("n", "<leader>gs", function()
				require("telescope.builtin").git_status()
			end, { desc = "Git status (Telescope)" })

			vim.keymap.set("n", "<leader>gc", function()
				-- Use telescope git_commits for commit history
				require("telescope.builtin").git_commits({
					theme = "dropdown",
					previewer = true,
					layout_config = {
						height = 0.8,
						width = 0.9,
						horizontal = {
							preview_width = 0.6,
						},
					},
				})
			end, { desc = "Git commits (Telescope)" })

			vim.keymap.set("n", "<leader>gb", function()
				-- Use telescope git_bcommits for current buffer commit history
				require("telescope.builtin").git_bcommits({
					theme = "dropdown",
					previewer = true,
					layout_config = {
						height = 0.8,
						width = 0.9,
						horizontal = {
							preview_width = 0.6,
						},
					},
				})
			end, { desc = "Git blame (Telescope)" })

			-- Regular fugitive commands for operations that can't use telescope
			vim.keymap.set("n", "<leader>gp", "<cmd>Git push<CR>", { desc = "Git push" })
			vim.keymap.set("n", "<leader>gl", "<cmd>Git pull<CR>", { desc = "Git pull" })
			vim.keymap.set("n", "<leader>gC", "<cmd>Git commit<CR>", { desc = "Open commit window" })

			-- Additional telescope git commands
			vim.keymap.set("n", "<leader>gB", function()
				-- Use telescope git_branches
				require("telescope.builtin").git_branches({
					theme = "dropdown",
					previewer = true,
					layout_config = {
						height = 0.8,
						width = 0.9,
						horizontal = {
							preview_width = 0.6,
						},
					},
				})
			end, { desc = "Git branches (Telescope)" })

			vim.keymap.set("n", "<leader>gS", function()
				-- Use telescope git_stash
				require("telescope.builtin").git_stash({
					theme = "dropdown",
					previewer = true,
					layout_config = {
						height = 0.8,
						width = 0.9,
						horizontal = {
							preview_width = 0.6,
						},
					},
				})
			end, { desc = "Git stash (Telescope)" })
		end,
	},
}
