#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting dotfiles bootstrap..."

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "Please wait for Xcode CLI tools to finish installing, then run this script again."
  exit 1
fi

if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -z "${DOTFILES_REPO:-}" ]; then
  echo "Set DOTFILES_REPO to your dotfiles repo URL before running bootstrap."
  echo 'Example: DOTFILES_REPO="https://github.com/your-user/dotfiles.git" bash bootstrap.sh'
  exit 1
fi

CHEZMOI_KEY="${HOME}/.config/chezmoi/key.txt"

if [ -f "$CHEZMOI_KEY" ]; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --force "$DOTFILES_REPO"
else
  echo "==> Age identity not found at $CHEZMOI_KEY"
  echo "==> Initializing chezmoi without apply..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --force "$DOTFILES_REPO"
  echo ""
  echo "==> Next steps"
  echo "  1. Restore your age identity to: $CHEZMOI_KEY"
  echo "  2. Run: chmod 600 $CHEZMOI_KEY"
  echo "  3. Run: chezmoi apply"
  exit 0
fi

echo ""
echo "==> Bootstrap complete!"
echo "  1. Back up ~/.config/chezmoi/key.txt securely before using another machine."
echo "  2. Verify SSH access with: ssh -T git@github.com"
echo "  3. Log in to your applications (Raycast, etc.)"
echo "  4. Restart your terminal."
