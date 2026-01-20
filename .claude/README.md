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

### How Skills Load

Skills are automatically loaded from `~/.claude/skills/`. The setup script creates symlinks from this directory to your dotfiles skills, so they're synced across machines via git but loaded from the standard Claude Code location.

```bash
~/.claude/skills/vikunja -> ~/dotfiles/.claude/plugins/personal/skills/vikunja
```

**Why symlinks?**
- Claude Code scans `~/.claude/skills/` at startup (and hot-reloads changes!)
- Dotfiles are synced via git and available at `~/.claude-config/` (symlink)
- Best of both worlds: Claude finds skills + version control

### Available Agents (Subagents)

**GitHub Issue Planner** (`agents/github-issue-planner.md`):
- Expert at parsing GitHub issues and creating actionable task breakdowns
- Invoked with: Task tool, subagent_type="github-issue-planner"
- Fetches issues using `gh` CLI
- Extracts requirements, acceptance criteria, and dependencies
- Creates detailed implementation plans
- Can handle single or multiple issues for sprint planning

**How to use:**
```
User: "Parse GitHub issue #123 and create tasks"
Assistant: [Uses Task tool with subagent_type="github-issue-planner"]
```

### How Agents Work

Agents are **custom subagent definitions** that you invoke via the Task tool. Unlike skills (which activate automatically), you explicitly call agents when you need specialized analysis or planning.

**Agents vs Skills:**
- **Skills**: Auto-activate based on keywords (e.g., "check my tasks" → Vikunja skill)
- **Agents**: Invoked via Task tool for specialized work (e.g., Task with github-issue-planner)

Agents are loaded from your plugin's `agents/` directory and are available across all projects.

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

## Adding New Agents

1. Create agent file: `plugins/personal/agents/my-agent.md`
2. Create markdown file with frontmatter:
   ```markdown
   ---
   name: my-agent
   description: When to use this agent (with examples showing invocation)
   tools: Bash, Glob, Grep, Read, WebFetch, TodoWrite
   model: sonnet
   color: blue
   ---

   # Agent system prompt and instructions here
   ```
3. Commit to dotfiles (agents are synced across machines)
4. Invoke using Task tool: `subagent_type="my-agent"`

**Agent frontmatter fields:**
- `name`: Agent identifier (used in Task tool)
- `description`: When/how to use (include usage examples)
- `tools`: Which tools agent can access (optional, defaults to all)
- `model`: sonnet, opus, haiku, or inherit
- `color`: UI color (blue, green, purple, etc.)
