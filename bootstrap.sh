#!/bin/bash
set -e

echo "==> Starting dotfiles bootstrap..."

# 1. Xcode CLI tools
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode CLI tools..."
  xcode-select --install
  echo "Poczekaj na instalację Xcode CLI tools, potem uruchom skrypt ponownie."
  exit 1
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Ensure brew is in PATH (works on both Apple Silicon and Intel)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

# 4. Bitwarden — unlock for SSH key retrieval
if ! command -v bw &>/dev/null; then
  echo "==> Installing Bitwarden CLI..."
  brew install bitwarden-cli
fi

BW_STATUS="$(bw status 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unauthenticated'))" 2>/dev/null || echo "unauthenticated")"

if [ "$BW_STATUS" = "unauthenticated" ]; then
  echo "==> Logging into Bitwarden..."
  BW_SESSION="$(bw login --raw)"
  export BW_SESSION
elif [ "$BW_STATUS" = "locked" ]; then
  echo "==> Unlocking Bitwarden..."
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
else
  echo "==> Bitwarden already unlocked."
fi

# 5. Clone dotfiles i apply (includes SSH key retrieval from Bitwarden)
echo "==> Applying dotfiles..."
chezmoi init --apply https://github.com/rlesniak/dotfiles.git

# 6. Brew bundle
echo "==> Installing packages from Brewfile..."
brew bundle --file="$(chezmoi source-path)/Brewfile"

# 7. Set fish as default shell
FISH_PATH="$(command -v fish 2>/dev/null)"
if [ -z "$FISH_PATH" ]; then
  # Fallback: detect brew prefix
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
fi

# 8. Fisher plugins
echo "==> Installing fish plugins..."
"$FISH_PATH" -c "fisher update" 2>/dev/null || echo "Note: fisher update failed, run manually: fisher update"

echo ""
echo "==> Bootstrap complete!"
echo ""
echo "Kolejne kroki:"
echo "  1. Klucze SSH pobrane automatycznie z Bitwarden."
echo "  2. Zaloguj się do aplikacji (Raycast, Pastebot, etc.)"
echo "  3. Uruchom terminal ponownie"
