# Claude Assistant Configuration

This directory contains configuration and credentials for Claude Code assistant to provide better context-aware help across all your projects.

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

4. Use stow to create the `~/.claude` symlink:
   ```bash
   cd ~/dotfiles
   stow .claude
   ```

5. Verify it works:
   ```bash
   cat ~/.claude/secrets/vikunja.json
   ```

## What Claude Can Access

When you work with Claude in any project, it can read:

- **Vikunja Tasks**: Your current todo list to understand priorities
- **GitHub Context**: Enhanced repository access and issue tracking
- **Preferences**: Task management settings

## Security

- All actual credentials live in `secrets/` which is gitignored
- Template files show structure but contain placeholder values
- Secrets never touch git history

## Adding New Services

1. Create template: `.claude/config/newservice.template.json`
2. Run `./setup.sh` to generate secrets file from template
3. Fill in actual credentials in `secrets/newservice.json`
4. Update this README with service description
