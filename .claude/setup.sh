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

echo ""
echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit the files in $SECRETS_DIR with your actual credentials"
echo "2. Run 'stow .claude' from ~/dotfiles to create ~/.claude symlink"
echo "3. Test with: cat ~/.claude/secrets/vikunja.json"
echo ""
