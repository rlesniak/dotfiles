#!/bin/bash
# Installs VS Code settings and extensions
# run_once_ means chezmoi runs this only once (tracks hash of script content)
set -e

VSCODE_USER="$HOME/Library/Application Support/Code/User"
SCRIPT_DIR="$(chezmoi source-path)"

# Copy settings
if [ -f "$SCRIPT_DIR/dot_config/vscode/settings.json" ]; then
  mkdir -p "$VSCODE_USER"
  cp "$SCRIPT_DIR/dot_config/vscode/settings.json" "$VSCODE_USER/settings.json"
  echo "VS Code settings installed."
fi

# Install extensions
if command -v code &>/dev/null && [ -f "$SCRIPT_DIR/dot_config/vscode/extensions.txt" ]; then
  while IFS= read -r ext; do
    [ -n "$ext" ] && code --install-extension "$ext" --force 2>/dev/null || true
  done < "$SCRIPT_DIR/dot_config/vscode/extensions.txt"
  echo "VS Code extensions installed."
fi
