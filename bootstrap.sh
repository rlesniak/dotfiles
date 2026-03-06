#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting dotfiles bootstrap..."

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "Please wait for Xcode CLI tools to finish installing, then run this script again."
  exit 1
fi

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --force https://github.com/rlesniak/dotfiles.git

echo "==> Fixing git remote to use HTTPS..."
CHEZMOI_SOURCE="${HOME}/.local/share/chezmoi"
if [[ -d "$CHEZMOI_SOURCE" ]]; then
  cd "$CHEZMOI_SOURCE"
  CURRENT_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ "$CURRENT_URL" == git@github.com:* ]]; then
    REPO_PATH="${CURRENT_URL#git@github.com:}"
    HTTPS_URL="https://github.com/${REPO_PATH}"
    git remote set-url origin "$HTTPS_URL"
    echo "==> Remote URL changed to: $HTTPS_URL"
  fi
fi

echo ""
echo "==> Bootstrap complete!"
echo "  1. Open Bitwarden Desktop, enable SSH Agent in Settings."
echo "  2. Import your SSH keys into Bitwarden vault."
echo "  3. Log in to your applications (Raycast, etc.)"
echo "  4. Restart your terminal."
