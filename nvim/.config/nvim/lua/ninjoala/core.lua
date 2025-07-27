-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git','clone','--filter=blob:none','https://github.com/folke/lazy.nvim.git','--branch=stable',lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins
require("lazy").setup("plugins")

-- Setup Mason packages after plugins are loaded (simplified)
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    -- Setup formatters and tools via mason.lua
    require("ninjoala.mason").setup()
    
    -- EMERGENCY: Kill all omnisharp processes
    vim.api.nvim_create_user_command("OmnisharpKill", function()
      vim.notify("🚨 EMERGENCY: Killing all Omnisharp processes...", vim.log.levels.WARN)
      -- Kill LSP clients first
      local clients = vim.lsp.get_clients({ name = "omnisharp" })
      for _, client in ipairs(clients) do
        client.stop(true) -- Force stop
      end
      -- Kill system processes
      vim.fn.system("pkill -f OmniSharp")
      vim.fn.system("pkill -f omnisharp") 
      vim.fn.system("pkill -f dotnet.*OmniSharp")
      vim.notify("✓ Omnisharp processes killed. System should be responsive now.", vim.log.levels.INFO)
    end, { desc = "EMERGENCY: Kill all Omnisharp processes" })
    
    -- Basic LSP utility commands
    vim.api.nvim_create_user_command("LspRestart", function()
      vim.notify("Restarting all LSP clients...", vim.log.levels.INFO)
      vim.cmd("LspStop")
      vim.defer_fn(function()
        vim.cmd("LspStart")
      end, 1000)
    end, { desc = "Restart all LSP clients" })
    
    vim.api.nvim_create_user_command("OmnisharpCheck", function()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/OmniSharp"
      if vim.fn.executable(mason_bin) == 1 then
        vim.notify("✓ Omnisharp executable found", vim.log.levels.INFO)
      else
        vim.notify("✗ Omnisharp not found. Install with :MasonInstall omnisharp", vim.log.levels.ERROR)
      end
      
      local clients = vim.lsp.get_clients({ name = "omnisharp" })
      if #clients > 0 then
        vim.notify("✓ " .. #clients .. " Omnisharp client(s) active", vim.log.levels.INFO)
        -- Check CPU usage
        local pid_check = vim.fn.system("pgrep -f OmniSharp | head -1 | tr -d '\n'")
        if pid_check ~= "" then
          local cpu_usage = vim.fn.system("ps -p " .. pid_check .. " -o %cpu --no-headers | tr -d ' \n'")
          if tonumber(cpu_usage) and tonumber(cpu_usage) > 50 then
            vim.notify("⚠️ WARNING: Omnisharp using " .. cpu_usage .. "% CPU!", vim.log.levels.WARN)
            vim.notify("Consider running :OmnisharpKill if system is slow", vim.log.levels.WARN)
          end
        end
      else
        vim.notify("ℹ No active Omnisharp clients", vim.log.levels.WARN)
      end
    end, { desc = "Check Omnisharp installation status" })
    
    vim.api.nvim_create_user_command("OmnisharpRestart", function()
      local clients = vim.lsp.get_clients({ name = "omnisharp" })
      for _, client in ipairs(clients) do
        client.stop(true) -- Force stop
      end
      -- Also kill system processes
      vim.fn.system("pkill -f OmniSharp")
      vim.notify("Omnisharp stopped. Will restart when opening C# file.", vim.log.levels.INFO)
    end, { desc = "Restart Omnisharp LSP" })
    
    -- Command to create omnisharp.json in project root
    vim.api.nvim_create_user_command("OmnisharpCreateConfig", function()
      local omnisharp_config = {
        DotNet = { EnablePackageRestore = false },
        FormattingOptions = {
          EnableEditorConfigSupport = false,
          OrganizeImports = false,
          NewLine = "\n",
          UseTabs = false,
          TabSize = 4,
          IndentationSize = 4
        },
        RoslynExtensionsOptions = {
          EnableAnalyzersSupport = false,
          EnableImportCompletion = false,
          EnableDecompilationSupport = false,
          LocationPaths = {}
        },
        MsBuild = {
          LoadProjectsOnDemand = false,
          EnablePackageAutoRestore = false,
          UseLegacySdkResolver = true,
          ToolsVersion = vim.NIL
        },
        Sdk = { IncludePrereleases = true },
        FileOptions = {
          SystemExcludeSearchPatterns = {
            "**/bin/**/*", "**/obj/**/*", "**/.git/**/*",
            "**/node_modules/**/*", "**/packages/**/*", "**/.vs/**/*"
          },
          ExcludeSearchPatterns = {}
        },
        Script = { EnableScriptNuGetReferences = false }
      }
      
      -- Find project root (look for .sln or .csproj)
      local root = vim.fn.getcwd()
      local current_file = vim.fn.expand('%:p:h')
      
      -- Try to find project root by looking for .sln or .csproj files
      local project_root = require('lspconfig.util').root_pattern("*.sln", "*.csproj")(current_file) or root
      
      local config_path = project_root .. "/omnisharp.json"
      
      -- Write the config file
      local file = io.open(config_path, "w")
      if file then
        file:write(vim.fn.json_encode(omnisharp_config))
        file:close()
        vim.notify("✓ Created omnisharp.json at: " .. config_path, vim.log.levels.INFO)
        vim.notify("This will disable analyzers for this project. Restart Omnisharp with :OmnisharpRestart", vim.log.levels.INFO)
      else
        vim.notify("✗ Failed to create omnisharp.json", vim.log.levels.ERROR)
      end
    end, { desc = "Create omnisharp.json config to disable analyzers" })
    
    -- C# filetype debugging (simplified)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function()
        vim.defer_fn(function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            vim.notify("⚠️  No LSP clients attached to C# file. Try :LspStart", vim.log.levels.WARN)
          end
        end, 2000)
      end,
    })
  end,
})

-- Netrw settings
vim.g.netrw_keepj = ""
vim.g.netrw_fastbrowse = 0

-- Core Neovim settings
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of keyword
opt.iskeyword:append("-")

-- Disable swapfile
opt.swapfile = false 