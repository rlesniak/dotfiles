#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting dotfiles bootstrap..."

# 1. Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "Please wait for Xcode CLI tools to finish installing, then run this script again."
  exit 1
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

# 4. Bitwarden CLI
if ! command -v bw &>/dev/null; then
  echo "==> Installing Bitwarden CLI..."
  brew install bitwarden-cli
fi

# 5. Bitwarden Unlock (needed BEFORE apply because of SSH templates)
# We keep this here because chezmoi templates need BW unlocked during apply
BW_STATUS="$(bw status 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unauthenticated'))" 2>/dev/null || echo "unauthenticated")"

if [[ "$BW_STATUS" == "unauthenticated" ]]; then
  echo "==> Logging into Bitwarden..."
  export BW_SESSION="$(bw login --raw)"
elif [[ "$BW_STATUS" == "locked" ]]; then
  echo "==> Unlocking Bitwarden..."
  export BW_SESSION="$(bw unlock --raw)"
fi

# 6. Initialize and apply chezmoi
echo "==> Initializing and applying chezmoi..."
# This will trigger .chezmoi.toml.tmpl prompts
chezmoi init --apply https://github.com/rlesniak/dotfiles.git

echo ""
echo "==> Bootstrap complete!"
echo "  1. SSH keys downloaded automatically from Bitwarden."
echo "  2. Log in to your applications (Raycast, Pastebot, etc.)"
echo "  3. Restart your terminal"
