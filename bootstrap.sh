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

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --force https://github.com/rlesniak/dotfiles.git

echo ""
echo "==> Bootstrap complete!"
echo "  1. Open Bitwarden Desktop, enable SSH Agent in Settings."
echo "  2. Import your SSH keys into Bitwarden vault."
echo "  3. Log in to your applications (Raycast, etc.)"
echo "  4. Restart your terminal."
