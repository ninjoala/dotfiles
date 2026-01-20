#!/bin/bash
set -e

echo "🤖 Setting up Claude Assistant Configuration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR/secrets"
CONFIG_DIR="$SCRIPT_DIR/config"

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

# Link skills to Claude's user skills directory
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

echo "📝 Linking skills to Claude Code..."

# Link all skills from personal plugin
for skill in "$SCRIPT_DIR/plugins/personal/skills"/*; do
    if [ -d "$skill" ]; then
        skill_name=$(basename "$skill")
        target="$SKILLS_DIR/$skill_name"

        if [ -L "$target" ]; then
            echo "✅ $skill_name skill already linked, skipping..."
        else
            ln -sf "$skill" "$target"
            echo "✅ Linked $skill_name skill"
        fi
    fi
done

# Link agents to Claude's user agents directory
AGENTS_DIR="$HOME/.claude/agents"
mkdir -p "$AGENTS_DIR"

echo "📝 Linking agents to Claude Code..."

# Link all agent files from personal plugin
for agent in "$SCRIPT_DIR/plugins/personal/agents"/*.md; do
    if [ -f "$agent" ] && [[ $(basename "$agent") != "USAGE_EXAMPLES.md" ]]; then
        agent_name=$(basename "$agent")
        target="$AGENTS_DIR/$agent_name"

        if [ -L "$target" ]; then
            echo "✅ $agent_name already linked, skipping..."
        else
            ln -sf "$agent" "$target"
            echo "✅ Linked $agent_name"
        fi
    fi
done

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit the files in $SECRETS_DIR with your actual credentials"
echo "2. Create symlink: ln -s ~/dotfiles/.claude ~/.claude-config"
echo "3. Restart Claude Code to load skills and agents (or wait for hot-reload)"
echo "4. Test skills with: 'check my tasks' in Claude"
echo "5. Test agents by invoking them via Task tool"
echo ""
echo "Skills linked in ~/.claude/skills/"
echo "Agents linked in ~/.claude/agents/"
echo ""
