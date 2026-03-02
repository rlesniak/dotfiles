#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting dotfiles bootstrap..."

###############################################################################
# 1. Xcode CLI tools                                                          #
###############################################################################

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "Please wait for Xcode CLI tools to finish installing, then run this script again."
  exit 1
fi

###############################################################################
# 2. Homebrew                                                                  #
###############################################################################

if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

###############################################################################
# 3. chezmoi                                                                   #
###############################################################################

if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

###############################################################################
# 4. Clone dotfiles + apply                                                    #
###############################################################################

echo "==> Initializing chezmoi..."
chezmoi init https://github.com/rlesniak/dotfiles.git

echo "==> Applying dotfiles..."
chezmoi apply

echo ""
echo "==> Bootstrap complete!"
echo "  1. Open Bitwarden Desktop, enable SSH Agent in Settings."
echo "  2. Import your SSH keys into Bitwarden vault."
echo "  3. Log in to your applications (Raycast, etc.)"
echo "  4. Restart your terminal."
