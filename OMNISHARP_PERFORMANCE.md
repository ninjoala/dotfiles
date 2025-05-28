# OmniSharp Performance Optimization Guide

This configuration implements aggressive performance optimizations to reduce OmniSharp's CPU and memory usage, making it more suitable for development in resource-constrained environments.

## 🚀 Key Optimizations

### Configuration Changes (`omnisharp.json.template`)

1. **Project Loading**: `LoadProjectsOnDemand: true` - Only loads projects when needed instead of all at startup
2. **Analyzers Disabled**: Completely disables Roslyn analyzers which are CPU-intensive
3. **Background Analysis**: Limited to open files only, no solution-wide analysis
4. **Package Restore**: Disabled to prevent network calls and file system operations
5. **Inlay Hints**: Disabled to reduce visual processing overhead
6. **File Exclusions**: Expanded to ignore more build artifacts and temporary files

### Neovim LSP Configuration

1. **Debounce**: Increased to 1000ms to reduce frequent updates
2. **Capabilities**: Aggressively disabled semantic tokens, formatting, symbols, etc.
3. **Command-line args**: Passes performance settings directly to OmniSharp
4. **Handlers**: Disables resource-intensive message handlers
5. **CPU Monitoring**: Automatically warns when CPU usage exceeds 20%

## 🛠️ Management Tools

### OmniSharp Manager Script

The `scripts/omnisharp-manager.sh` script provides several commands:

```bash
# Check current status and resource usage
./scripts/omnisharp-manager.sh status

# Monitor processes for 60 seconds (or specify duration)
./scripts/omnisharp-manager.sh monitor
./scripts/omnisharp-manager.sh monitor 120  # 2 minutes

# Gracefully stop all OmniSharp processes
./scripts/omnisharp-manager.sh kill

# Force stop all OmniSharp processes
./scripts/omnisharp-manager.sh force-kill
```

### Neovim Commands

Your Neovim config includes these emergency commands:

- `:OmnisharpKill` - Emergency kill all OmniSharp processes
- `:OmnisharpRestart` - Restart OmniSharp LSP
- `:OmnisharpCheck` - Check installation and process status
- `:OmnisharpCreateConfig` - Create project-specific omnisharp.json

## 📊 Expected Performance Improvements

### Before Optimization
- **Startup**: 5-15 seconds, high CPU usage
- **Memory**: 300-800MB per project
- **CPU**: 40-80% during analysis
- **Responsiveness**: Sluggish during background analysis

### After Optimization
- **Startup**: 1-3 seconds, minimal CPU usage
- **Memory**: 100-300MB per project
- **CPU**: 5-20% during normal usage
- **Responsiveness**: Much more responsive

## 🔧 What You Lose vs Gain

### Disabled Features
- ❌ Code analyzers and linting
- ❌ Automatic code fixes and refactoring suggestions
- ❌ Semantic highlighting
- ❌ Document formatting
- ❌ Symbol search across entire solution
- ❌ Inlay hints for parameters and types
- ❌ Decompilation support

### What Still Works
- ✅ Basic IntelliSense and completions
- ✅ Go to definition/references
- ✅ Error highlighting for open files
- ✅ Basic diagnostics
- ✅ Hover information
- ✅ File and project navigation

## 🎯 Usage Recommendations

### For Resource-Constrained Systems
- Use the optimized config as-is
- Monitor with `./scripts/omnisharp-manager.sh monitor`
- Kill processes when CPU usage exceeds 25%

### For Better Development Experience
If you need more features but want to keep performance reasonable:

1. **Re-enable analyzers selectively**:
   ```json
   "RoslynExtensionsOptions": {
     "EnableAnalyzersSupport": true,  // Only for critical projects
   }
   ```

2. **Enable formatting for specific projects**:
   ```json
   "FormattingOptions": {
     "EnableEditorConfigSupport": true,
   }
   ```

3. **Use project-specific configs**:
   - Run `:OmnisharpCreateConfig` in projects where you need more features
   - Keep the global config minimal

## 🔍 Troubleshooting

### OmniSharp Still Using High CPU
1. Check if multiple instances are running: `./scripts/omnisharp-manager.sh status`
2. Kill all processes: `./scripts/omnisharp-manager.sh kill`
3. Check if project has many files: add more exclusion patterns
4. Consider using single-file mode for small edits

### IntelliSense Not Working
1. Restart OmniSharp: `:OmnisharpRestart`
2. Check if .NET SDK is installed: `dotnet --version`
3. Verify project files exist: look for `.csproj` or `.sln` files
4. Check Neovim LSP logs: `:LspLog`

### System Still Slow
1. Monitor other processes: `htop` or `top`
2. Check disk I/O: OmniSharp might be scanning files
3. Verify exclusion patterns are working
4. Consider using VS Code for heavy development sessions

## 🚨 Emergency Procedures

If your system becomes unresponsive:

1. **Kill OmniSharp immediately**:
   ```bash
   pkill -9 -f OmniSharp
   # or from Neovim:
   :OmnisharpKill
   ```

2. **Prevent auto-restart**: Close all C# files in your editor

3. **System-wide cleanup**:
   ```bash
   ./scripts/omnisharp-manager.sh force-kill
   sudo pkill -f dotnet  # If needed
   ```

## 🔄 Reverting Changes

To restore full OmniSharp functionality:

1. **Global config**: Edit `omnisharp.json` in your projects and enable features
2. **Neovim config**: Comment out the aggressive capability disabling in LSP setup
3. **Restart**: `:OmnisharpRestart` or restart Neovim

Remember: The point of these optimizations is to make OmniSharp usable on resource-constrained systems. If you have sufficient resources, you might prefer the full feature set. 