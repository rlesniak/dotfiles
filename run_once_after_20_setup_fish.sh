#!/bin/bash
set -eufo pipefail

echo "==> Setting up fish shell..."

FISH_PATH="$(command -v fish 2>/dev/null || true)"
if [ -z "$FISH_PATH" ]; then
  BREW_PREFIX="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"
  FISH_PATH="$BREW_PREFIX/bin/fish"
fi

if [ -f "$FISH_PATH" ]; then
  if ! grep -qF "$FISH_PATH" /etc/shells; then
    echo "==> Adding fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi
  if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "==> Setting fish as default shell..."
    chsh -s "$FISH_PATH"
  fi
  
  echo "==> Installing fish plugins..."
  "$FISH_PATH" -c "fisher update" 2>/dev/null || echo "Note: fisher update failed, run manually: fisher update"
fi
