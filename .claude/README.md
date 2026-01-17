# Claude Assistant Configuration

This directory contains configuration and credentials for Claude Code assistant to provide better context-aware help across all your projects.

**Note**: This config lives at `~/.claude-config` (not `~/.claude`) because Claude Code uses `~/.claude` for its own internal configuration.

## Structure

- **config/**: Template files (committed to git)
- **secrets/**: Actual credentials (gitignored, local only)
- **setup.sh**: Script to copy templates to secrets

## Setup on New Machine

1. Clone your dotfiles repository
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script to copy templates:
   ```bash
   cd .claude
   chmod +x setup.sh
   ./setup.sh
   ```

3. Edit files in `secrets/` directory with your actual credentials:
   ```bash
   # Edit with your Vikunja API token
   nano secrets/vikunja.json
   # Or use your preferred editor
   ```

4. Create the `~/.claude-config` symlink:
   ```bash
   # Direct symlink (we don't use stow here because Claude Code already uses ~/.claude)
   ln -s ~/dotfiles/.claude ~/.claude-config
   ```

5. Verify it works:
   ```bash
   cat ~/.claude-config/secrets/vikunja.json
   ```

## How to Use With Claude

Claude doesn't automatically read this config. Instead, use these simple commands:

**To access your Vikunja tasks:**
- Say: "**check my tasks**" or "**read my Vikunja tasks**"
- Claude will:
  1. Read `~/.claude-config/secrets/vikunja.json` for credentials
  2. Fetch your current tasks via the Vikunja API
  3. Show them to you

**What's stored here:**
- **Vikunja credentials**: API URL and token for task management
- **GitHub token**: For enhanced repository access
- **Preferences**: Task management settings

## Security

- All actual credentials live in `secrets/` which is gitignored
- Template files show structure but contain placeholder values
- Secrets never touch git history

## Plugins and Skills

This directory includes a custom `personal` plugin with skills that Claude automatically uses.

### Available Skills

**Vikunja** (`skills/vikunja/`):
- Automatically activates when you mention tasks, Vikunja, or todo management
- Connects to todo.dobosprime.com
- Can list, create, update, and complete tasks
- Uses credentials from `secrets/vikunja.json`

### How Skills Work

Skills are **automatically invoked** by Claude when relevant. You don't need to explicitly call them.

**Example conversations:**
- "Show me my Boosted tasks" → Claude uses Vikunja skill
- "Add task to finish the landing page" → Claude creates task via API
- "Check my tasks" → Claude fetches and displays your Vikunja todos

### Plugin Loading

The `settings.json` file configures Claude to automatically load plugins from `~/.claude-config/plugins/personal` on every session.

## Adding New Services

1. Create template: `.claude/config/newservice.template.json`
2. Run `./setup.sh` to generate secrets file from template
3. Fill in actual credentials in `secrets/newservice.json`
4. Update this README with service description

## Adding New Skills

1. Create skill directory: `plugins/personal/skills/my-skill/`
2. Create `SKILL.md` with frontmatter:
   ```markdown
   ---
   name: my-skill
   description: When to use this skill (trigger phrases, keywords)
   version: 1.0.0
   ---

   # Skill instructions here
   ```
3. Commit to dotfiles (skills are synced across machines)
4. Claude will automatically use it when relevant
