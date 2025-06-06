return {
  -- Theme
  {
    'Mofiqul/vscode.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('vscode').setup({
        -- Enable transparent background
        transparent = true,
        -- Enable italic comments
        italic_comments = true,
        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,
        -- Override colors (optional)
        color_overrides = {
          vscLineNumber = '#FFFFFF',
        },
      })
      -- Load the colorscheme
      vim.cmd.colorscheme('vscode')
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
    priority = 900,  -- Load right after theme but before other plugins
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        },
        border = "rounded",
        width = 0.8,
        height = 0.8
      },
      max_concurrent_installers = 4,
    },
  },

  -- Mason-LSPConfig bridge
  {
    'williamboman/mason-lspconfig.nvim',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { 
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { 
        'lua_ls',
        'omnisharp', 
        'pyright', 
        'ts_ls',
        'html',
        'cssls',
        'jsonls'
      },
      automatic_installation = true,
      handlers = nil,
    },
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Global diagnostic configuration (single source of truth)
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Set LSP log level
      vim.lsp.set_log_level("WARN")

      -- Default LSP servers (simple setup)
      local simple_servers = { 'lua_ls', 'pyright', 'ts_ls', 'html', 'cssls', 'jsonls' }
      for _, server in ipairs(simple_servers) do
        lspconfig[server].setup({
          capabilities = capabilities,
        })
      end

      -- Omnisharp (complex setup with error fixes)
      lspconfig.omnisharp.setup({
        capabilities = capabilities,
        cmd = { 
          vim.fn.stdpath("data") .. "/mason/bin/OmniSharp", 
          "--languageserver", 
          "--hostPID", tostring(vim.fn.getpid()),
          -- Resource limits and aggressive optimizations
          "--DotNet:EnablePackageRestore=false",
          "--RoslynExtensionsOptions:EnableAnalyzersSupport=false",
          "--RoslynExtensionsOptions:EnableImportCompletion=false", 
          "--RoslynExtensionsOptions:EnableDecompilationSupport=false",
          "--RoslynExtensionsOptions:EnableAsyncCompletion=false",
          "--FormattingOptions:EnableEditorConfigSupport=false",
          "--MsBuild:LoadProjectsOnDemand=true",
          "--MsBuild:EnablePackageAutoRestore=false",
          "--MsBuild:UseLegacySdkResolver=true",
          "--MsBuild:SkipNonexistentProjectFiles=true",
          "--Sdk:IncludePrereleases=false",
          "--Script:EnableScriptNuGetReferences=false",
          "--BackgroundAnalysis:AnalyzerDiagnosticsScope=none",
          "--BackgroundAnalysis:CompilerDiagnosticsScope=openFiles",
          -- File exclusions to reduce scanning
          "--FileOptions:SystemExcludeSearchPatterns:0=**/bin/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:1=**/obj/**/*", 
          "--FileOptions:SystemExcludeSearchPatterns:2=**/.git/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:3=**/node_modules/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:4=**/packages/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:5=**/.vs/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:6=**/TestResults/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:7=**/.vscode/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:8=**/coverage/**/*",
          "--FileOptions:SystemExcludeSearchPatterns:9=**/*.log",
          "--FileOptions:SystemExcludeSearchPatterns:10=**/logs/**/*",
          -- Memory and performance limits
          "--Assembly:LoadFromDisk=false"
        },
        filetypes = { "cs" },
        root_dir = function(fname)
          -- Simplified root detection to avoid excessive file scanning
          local util = require('lspconfig.util')
          return util.root_pattern("*.sln", "*.csproj")(fname) or util.path.dirname(fname)
        end,
        single_file_support = true,
        -- Add timeout and resource limits
        flags = {
          debounce_text_changes = 1000, -- Increase debounce to reduce CPU
          allow_incremental_sync = false, -- Disable incremental sync
          exit_timeout = 3000, -- 3 second timeout
        },
        on_attach = function(client, bufnr)
          -- AGGRESSIVELY disable ALL resource-intensive capabilities
          client.server_capabilities.semanticTokensProvider = nil
          client.server_capabilities.documentFormattingProvider = nil
          client.server_capabilities.documentRangeFormattingProvider = nil
          client.server_capabilities.documentSymbolProvider = nil
          client.server_capabilities.workspaceSymbolProvider = nil
          client.server_capabilities.codeActionProvider = nil
          client.server_capabilities.documentLinkProvider = nil
          client.server_capabilities.foldingRangeProvider = nil
          client.server_capabilities.selectionRangeProvider = nil
          client.server_capabilities.callHierarchyProvider = nil
          client.server_capabilities.documentHighlightProvider = nil
          client.server_capabilities.inlayHintProvider = nil
          -- Disable workspace features
          client.server_capabilities.workspace = nil
          
          -- Monitor CPU usage and warn
          vim.defer_fn(function()
            local pid_check = vim.fn.system("pgrep -f OmniSharp | head -1 | tr -d '\n'")
            if pid_check ~= "" then
              local cpu_usage = vim.fn.system("ps -p " .. pid_check .. " -o %cpu --no-headers | tr -d ' \n'")
              if tonumber(cpu_usage) and tonumber(cpu_usage) > 20 then
                vim.notify("⚠️ Omnisharp using " .. cpu_usage .. "% CPU. Consider :OmnisharpKill", vim.log.levels.WARN)
              end
            end
          end, 3000)
          
          vim.notify("✓ Ultra-minimal Omnisharp attached to " .. vim.fn.expand('%:t'), vim.log.levels.INFO)
        end,
        -- Ultra-minimal settings
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = false,
            OrganizeImports = false,
          },
          MsBuild = {
            LoadProjectsOnDemand = true,
            EnablePackageAutoRestore = false,
            UseLegacySdkResolver = true,
            SkipNonexistentProjectFiles = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = false,
            EnableImportCompletion = false,
            EnableDecompilationSupport = false,
            EnableAsyncCompletion = false,
            LocationPaths = {},
          },
          Sdk = {
            IncludePrereleases = false,
          },
          FileOptions = {
            SystemExcludeSearchPatterns = {
              "**/bin/**/*", "**/obj/**/*", "**/.git/**/*", 
              "**/node_modules/**/*", "**/packages/**/*", 
              "**/.vs/**/*", "**/TestResults/**/*", "**/.vscode/**/*",
              "**/coverage/**/*", "**/*.log", "**/logs/**/*"
            },
            ExcludeSearchPatterns = {},
          },
          -- Disable background analysis
          BackgroundAnalysis = {
            AnalyzerDiagnosticsScope = "none",
            CompilerDiagnosticsScope = "openFiles"
          },
          InlayHints = {
            EnableForParameters = false,
            EnableForLiterals = false,
            EnableForIndexerParameters = false,
            EnableForObjectCreationParameters = false,
            EnableForOtherParameters = false,
          }
        },
        init_options = {
          ["DotNet:EnablePackageRestore"] = false,
          ["RoslynExtensionsOptions:EnableAnalyzersSupport"] = false,
          ["RoslynExtensionsOptions:EnableAsyncCompletion"] = false,
          ["FormattingOptions:EnableEditorConfigSupport"] = false,
          ["BackgroundAnalysis:AnalyzerDiagnosticsScope"] = "none",
          ["BackgroundAnalysis:CompilerDiagnosticsScope"] = "openFiles",
          ["MsBuild:LoadProjectsOnDemand"] = true,
        },
        handlers = {
          -- Disable ALL resource-intensive handlers
          ["textDocument/semanticTokens/full"] = function() end,
          ["textDocument/semanticTokens/range"] = function() end,
          ["textDocument/documentSymbol"] = function() end,
          ["workspace/symbol"] = function() end,
          ["textDocument/codeAction"] = function() end,
          ["textDocument/formatting"] = function() end,
          ["textDocument/rangeFormatting"] = function() end,
          ["textDocument/inlayHint"] = function() end,
          ["textDocument/documentHighlight"] = function() end,
          ["window/logMessage"] = function(err, result, ctx)
            -- Filter out ALL non-critical messages
            if result and result.message then
              local msg = result.message:lower()
              if string.find(msg, "analyzer") or 
                 string.find(msg, "microsoft.codeanalysis") or
                 string.find(msg, "microsoft.extensions") or
                 string.find(msg, "loading") or
                 string.find(msg, "package") or
                 string.find(msg, "restore") or
                 string.find(msg, "project") then
                return  -- Silently ignore
              end
            end
            -- Only show errors and critical info
            if result and result.type <= 1 then -- Error level
              vim.lsp.handlers["window/logMessage"](err, result, ctx)
            end
          end,
        }
      })
    end,
  },

  -- Autocompletion (simplified, removed lsp-zero dependency)
  {
    "hrsh7th/nvim-cmp",
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
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
    end
  },

  -- Treesitter (properly configured)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "vim", "lua", "vimdoc",
          "html", "css", "javascript", "typescript",
          "c_sharp", "python", "json", "bicep"
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
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
        build = "make"  -- Simplified build command
      }
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
            previewer = require('telescope.previewers').new_termopen_previewer({
              get_command = function(entry)
                if entry.status == '??' or entry.status == 'A ' then
                  return { 'cat', entry.path }
                end
                return {
                  'git',
                  '-c', 'color.diff=always',
                  '-c', 'color.ui=always',
                  '-c', 'color.status=always',
                  'diff',
                  '--no-color-moved',
                  '--color=always',
                  entry.path
                }
              end
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
        }
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
      vim.keymap.set('n', '<leader>ct', '<cmd>checktime<CR>', { desc = 'Check for file changes' })

      require('gitsigns').setup({
        signs = {
          add = { text = '│' },
          change = { text = '│' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Navigation
          vim.keymap.set('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer=bufnr})

          vim.keymap.set('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, buffer=bufnr})

          -- View hunks
          vim.keymap.set('n', '<leader>gL', function()
            gs.setqflist('all')
            vim.defer_fn(function()
              vim.cmd('cclose') -- Close the quickfix window if it's open
              require('telescope.builtin').quickfix({ 
                theme = "dropdown",
              })
            end, 100)
          end, {buffer = bufnr, desc = 'List git hunks'})

          -- Preview hunk inline
          vim.keymap.set('n', '<leader>hl', gs.preview_hunk, {buffer = bufnr, desc = 'Preview git hunk'})
        end
      })
    end,
  },

  -- Status line (properly configured)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup({
        options = {
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      })
    end,
  },

  -- Portal.nvim for enhanced jump navigation
  {
    "cbochs/portal.nvim",
    dependencies = {
      "ThePrimeagen/harpoon", -- Optional: for harpoon list support
    },
    config = function()
      require("portal").setup({
        -- Default settings
        labels = { "j", "k", "h", "l" }, -- Portal labels for jumping
        window = {
          border = "rounded",     -- Border style
          position = "bottom",    -- Position of the window
          width = 0.4,           -- Width of the window (percentage or integer)
          height = 0.4,          -- Height of the window (percentage or integer)
        },
      })

      -- Keybindings
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }
      
      -- Portal navigation
      keymap("n", "<C-o>", "<cmd>Portal jumplist backward<CR>", { desc = "Portal Backward" })
      keymap("n", "<C-i>", "<cmd>Portal jumplist forward<CR>", { desc = "Portal Forward" })
    end
  },

  -- Fugitive for Git commands
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
    config = function()
      -- Add keymaps that integrate with telescope where possible
      vim.keymap.set("n", "<leader>gs", function()
        require('telescope.builtin').git_status()
      end, { desc = "Git status (Telescope)" })

      vim.keymap.set("n", "<leader>gc", function()
        -- Use telescope git_commits for commit history
        require('telescope.builtin').git_commits({
          theme = "dropdown",
          previewer = true,
          layout_config = {
            height = 0.8,
            width = 0.9,
            horizontal = {
              preview_width = 0.6,
            }
          },
        })
      end, { desc = "Git commits (Telescope)" })

      vim.keymap.set("n", "<leader>gb", function()
        -- Use telescope git_bcommits for current buffer commit history
        require('telescope.builtin').git_bcommits({
          theme = "dropdown",
          previewer = true,
          layout_config = {
            height = 0.8,
            width = 0.9,
            horizontal = {
              preview_width = 0.6,
            }
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
        require('telescope.builtin').git_branches({
          theme = "dropdown",
          previewer = true,
          layout_config = {
            height = 0.8,
            width = 0.9,
            horizontal = {
              preview_width = 0.6,
            }
          },
        })
      end, { desc = "Git branches (Telescope)" })

      vim.keymap.set("n", "<leader>gS", function()
        -- Use telescope git_stash
        require('telescope.builtin').git_stash({
          theme = "dropdown",
          previewer = true,
          layout_config = {
            height = 0.8,
            width = 0.9,
            horizontal = {
              preview_width = 0.6,
            }
          },
        })
      end, { desc = "Git stash (Telescope)" })
    end,
  },
} 
