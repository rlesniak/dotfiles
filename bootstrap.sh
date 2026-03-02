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
# 3. chezmoi + age                                                             #
###############################################################################

if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

if ! command -v age &>/dev/null; then
  echo "==> Installing age..."
  brew install age
fi

###############################################################################
# 4. age key                                                                   #
###############################################################################

AGE_KEY="$HOME/.config/chezmoi/key.txt"

if [[ ! -f "$AGE_KEY" ]]; then
  echo ""
  echo "==> age key not found at $AGE_KEY"
  echo "    Paste the contents of your age key (from Bitwarden safe note),"
  echo "    then press Ctrl+D when done:"
  echo ""
  mkdir -p "$(dirname "$AGE_KEY")"
  cat > "$AGE_KEY"
  chmod 600 "$AGE_KEY"
  echo ""
  echo "==> age key saved."
fi

###############################################################################
# 5. Clone dotfiles + apply                                                    #
###############################################################################

echo "==> Initializing chezmoi..."
chezmoi init https://github.com/rlesniak/dotfiles.git

echo "==> Applying dotfiles..."
chezmoi apply

echo ""
echo "==> Bootstrap complete!"
echo "  1. SSH keys decrypted from repo automatically."
echo "  2. Log in to your applications (Raycast, etc.)"
echo "  3. Restart your terminal."
