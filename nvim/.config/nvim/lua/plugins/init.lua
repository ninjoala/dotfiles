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
    "williamboman/mason.nvim",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },

  {
    'williamboman/mason-lspconfig.nvim',
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = { 'lua_ls' },
      automatic_installation = true,
      handlers = {
        function(server_name)
          -- Skip OmniSharp since we're using roslyn
          if server_name == "omnisharp" then
            return
          end
          require("lspconfig")[server_name].setup {}
        end,
      },
    },
  },

  -- Make sure roslyn.nvim is loaded before lspconfig
  {
    "seblyng/roslyn.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    ft = "cs",
    config = function()
      local roslyn = require("roslyn")
      roslyn.setup({
        cmd = { "dotnet", vim.fn.stdpath("data") .. "/mason/packages/roslyn/Microsoft.CodeAnalysis.LanguageServer.dll", "--stdio" },
        on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
          vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        filewatching = "auto",
        broad_search = true,
        lock_target = false,
      })
    end
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
      
      -- Disable semantic tokens in capabilities
      capabilities.textDocument.semanticTokens = nil
      
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
      end

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
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        })
      })
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c_sharp",
        "bicep"
      },
    },
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
          buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
          preview = {
            hide_on_startup = true
          }
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
        }
      })
      -- Only try to load fzf if it exists
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },
} 