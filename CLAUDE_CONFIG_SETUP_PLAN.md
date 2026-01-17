# Claude Assistant Config Setup Plan

## Goal
Create a `.claude` configuration directory in dotfiles that allows Claude to access user context (Vikunja tasks, GitHub tokens, project preferences, etc.) across all machines while keeping secrets gitignored.

## Directory Structure to Create

```
~/dotfiles/.claude/
├── README.md                           # Documentation for the config system
├── setup.sh                            # Setup script for new machines
├── config/                             # Config templates (committed to git)
│   ├── vikunja.template.json
│   ├── github.template.json
│   └── preferences.json               # Non-secret preferences
└── secrets/                            # Actual secrets (gitignored)
    ├── vikunja.json
    └── github.json
```

## Implementation Steps

### Step 1: Create Directory Structure
```bash
cd ~/dotfiles
mkdir -p .claude/config
mkdir -p .claude/secrets
```

### Step 2: Create .gitignore Entry
Add to `~/dotfiles/.gitignore`:
```
# Claude Assistant Secrets
.claude/secrets/
```

### Step 3: Create Template Files

**File: `.claude/config/vikunja.template.json`**
```json
{
  "apiUrl": "https://your-vikunja-instance.com",
  "apiToken": "your_vikunja_api_token_here",
  "defaultListId": null,
  "description": "Vikunja task management API credentials"
}
```

**File: `.claude/config/github.template.json`**
```json
{
  "token": "ghp_your_github_token_here",
  "defaultOrg": "your-github-org",
  "description": "GitHub API token for enhanced repository access"
}
```

**File: `.claude/config/preferences.json`** (non-secret, safe to commit)
```json
{
  "defaultEditor": "cursor",
  "projectsDirectory": "~/Projects",
  "workingHours": {
    "start": "09:00",
    "end": "17:00",
    "timezone": "America/New_York"
  },
  "taskManagement": {
    "preferVikunja": true,
    "syncWithGitHub": false
  }
}
```

### Step 4: Create Setup Script

**File: `.claude/setup.sh`**
```bash
#!/bin/bash
set -e

echo "🤖 Setting up Claude Assistant Configuration..."

CLAUDE_DIR="$HOME/dotfiles/.claude"
SECRETS_DIR="$CLAUDE_DIR/secrets"
CONFIG_DIR="$CLAUDE_DIR/config"

# Ensure secrets directory exists
mkdir -p "$SECRETS_DIR"

# Copy templates to secrets if they don't exist
for template in "$CONFIG_DIR"/*.template.json; do
    filename=$(basename "$template" .template.json)
    target="$SECRETS_DIR/${filename}.json"

    if [ ! -f "$target" ]; then
        echo "📝 Creating $target from template..."
        cp "$template" "$target"
        echo "⚠️  Please edit $target and add your actual credentials"
    else
        echo "✅ $target already exists, skipping..."
    fi
done

# Create symlink in home directory
if [ ! -L "$HOME/.claude" ]; then
    echo "🔗 Creating symlink: ~/.claude -> ~/dotfiles/.claude"
    ln -s "$CLAUDE_DIR" "$HOME/.claude"
else
    echo "✅ Symlink ~/.claude already exists"
fi

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit the files in $SECRETS_DIR with your actual credentials"
echo "2. Test with: cat ~/.claude/secrets/vikunja.json"
echo ""
```

### Step 5: Create README

**File: `.claude/README.md`**
```markdown
# Claude Assistant Configuration

This directory contains configuration and credentials for Claude Code assistant to provide better context-aware help across all your projects.

## Structure

- **config/**: Template files (committed to git)
- **secrets/**: Actual credentials (gitignored, local only)
- **setup.sh**: Setup script for new machines

## Setup on New Machine

1. Clone your dotfiles repository
2. Run the setup script:
   ```bash
   cd ~/dotfiles/.claude
   chmod +x setup.sh
   ./setup.sh
   ```
3. Edit files in `secrets/` directory with your actual credentials:
   - `secrets/vikunja.json` - Your Vikunja API token
   - `secrets/github.json` - Your GitHub personal access token

## What Claude Can Access

When you work with Claude in any project, it can read:

- **Vikunja Tasks**: Your current todo list to understand priorities
- **GitHub Context**: Enhanced repository access and issue tracking
- **Preferences**: Your working hours, preferred tools, project locations

## Security

- All actual credentials live in `secrets/` which is gitignored
- Template files show structure but contain placeholder values
- Even on private Gitea, secrets never touch git history

## Adding New Services

1. Create template: `.claude/config/newservice.template.json`
2. Run `./setup.sh` to generate secrets file
3. Update this README with service description
```

### Step 6: Make Setup Script Executable
```bash
chmod +x ~/dotfiles/.claude/setup.sh
```

### Step 7: Run Setup Script
```bash
cd ~/dotfiles/.claude
./setup.sh
```

### Step 8: Fill in Actual Credentials

After running setup script, edit these files with real values:
- `~/dotfiles/.claude/secrets/vikunja.json`
- `~/dotfiles/.claude/secrets/github.json`

### Step 9: Test Access

Verify Claude can read the config:
```bash
cat ~/.claude/secrets/vikunja.json
cat ~/.claude/config/preferences.json
```

### Step 10: Commit to Gitea

```bash
cd ~/dotfiles
git add .claude/
git add .gitignore
git commit -m "Add Claude assistant configuration system

- Template files for Vikunja, GitHub credentials
- Setup script for new machines
- Secrets directory gitignored for security
- Preferences file for non-secret settings"
git push origin main
```

## Expected Outcome

After completion:
- ✅ `~/.claude` symlink points to `~/dotfiles/.claude`
- ✅ Claude can read your Vikunja tasks from any project directory
- ✅ Templates are version controlled in git
- ✅ Actual secrets are local-only (gitignored)
- ✅ Easy to set up on new machines with `./setup.sh`
- ✅ Extensible for future services (Jira, Linear, etc.)

## User Action Required After Agent Completes

You must manually edit `~/.claude/secrets/vikunja.json` with your actual Vikunja credentials:
1. Get API token from your Vikunja instance (Settings → API Tokens)
2. Replace placeholders in the secrets file
3. Test by running: `curl -H "Authorization: Bearer YOUR_TOKEN" https://your-vikunja/api/v1/tasks`

## Notes for Future

This pattern can be extended for:
- Jira/Linear API tokens
- Database connection strings (non-production)
- Custom AI service keys
- Project-specific preferences
- Team collaboration settings
