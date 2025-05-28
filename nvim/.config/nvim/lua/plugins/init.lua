return {
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = true,
        terminal_colors = true,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Rose-Pine theme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1001,
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- LSP Support
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = true,
    config = false,
    init = function()
      -- Disable automatic setup, we are doing it manually
      vim.g.lsp_zero_extend_cmp = 0
      vim.g.lsp_zero_extend_lspconfig = 0
    end,
  },
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = true,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    dependencies = { 'williamboman/mason.nvim' },
    config = true,
    opts = {
      ensure_installed = { 'lua_ls', 'omnisharp', 'pyright', 'ts_ls'},
      automatic_installation = true,
      handlers = {
        function(server_name)
          -- Skip servers that we configure manually
          if server_name == "omnisharp" or
             server_name == "pyright" or
             server_name == "ts_ls" then
            return
          end
          require("lspconfig")[server_name].setup {}
        end,
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
      {'williamboman/mason-lspconfig.nvim'},
    },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
      end

      -- OmniSharp (C#)
      lspconfig.omnisharp.setup {
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/omnisharp", "--languageserver" },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable semantic tokens
          client.server_capabilities.semanticTokensProvider = nil
          on_attach(client, bufnr)
        end,
        filetypes = { "cs" },  -- Simplified filetypes
        root_dir = require('lspconfig.util').root_pattern("*.sln", "*.csproj", ".git"),
        handlers = {
          ["textDocument/definition"] = vim.lsp.handlers["textDocument/definition"],
          ["textDocument/references"] = vim.lsp.handlers["textDocument/references"],
          ["textDocument/implementation"] = vim.lsp.handlers["textDocument/implementation"]
        },
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = false,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = false,
            EnableDecompilationSupport = false,
            EnableImportCompletion = false,
          },
          SDK = {
            IncludePrereleases = true,
          },
          enableSemanticHighlighting = false,
          enableSemanticTokens = false,
        },
        -- Enable this to see LSP log messages
        init_options = {
          -- Disable analyzers
          RoslynExtensionsOptions = {
            enableAnalyzersSupport = false,
            enableDecompilationSupport = false,
            enableImportCompletion = false,
          },
          -- Disable semantic tokens
          enableSemanticHighlighting = false,
          enableSemanticTokens = false,
        }
      }

      -- Python LSP (Pyright)
      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local pyright_path = mason_path .. "/packages/pyright/node_modules/pyright/langserver.index.js"
      lspconfig.pyright.setup {
        cmd = { "node", pyright_path, "--stdio" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true
            }
          }
        },
        root_dir = require('lspconfig.util').root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git"),
      }

      -- JavaScript/TypeScript LSP (ts_ls)
      lspconfig.ts_ls.setup {
        cmd = { vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        root_dir = require('lspconfig.util').root_pattern(
          "tsconfig.json",
          "jsconfig.json",
          "package.json",
          ".git"
        ),
        single_file_support = true,
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      cmp.setup({
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        })
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
      }
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
          path_display = { "truncate" },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
          },
          live_grep = {
            theme = "dropdown",
            additional_args = function()
              return {"--hidden"}
            end
          },
        },
      })
      -- Only try to load fzf if it exists
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },
} 