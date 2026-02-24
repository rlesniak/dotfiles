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

# 3. chezmoi (needed to locate Brewfile)
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

# 4. Clone dotfiles repo (without apply) to get Brewfile
if [ ! -d "$(chezmoi source-path 2>/dev/null)" ]; then
  echo "==> Cloning dotfiles..."
  chezmoi init https://github.com/rlesniak/dotfiles.git
fi

# 5. chezmoi.toml — ensure Bitwarden item IDs are configured locally
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
if ! grep -q "bw_id_rlesniak" "$CHEZMOI_CONFIG" 2>/dev/null; then
  echo ""
  echo "==> Bitwarden SSH key IDs not found in chezmoi config."
  echo "    These are the Bitwarden item IDs for your SSH keys (not passwords)."
  echo "    Find them with: bw list items --search 'SSH Key'"
  echo ""
  read -rp "    Bitwarden item ID for id_rlesniak:  " BW_ID_RLESNIAK
  read -rp "    Bitwarden item ID for id_rsa_akiro: " BW_ID_RSA_AKIRO
  mkdir -p "$(dirname "$CHEZMOI_CONFIG")"
  if grep -q "sourceDir" "$CHEZMOI_CONFIG" 2>/dev/null; then
    # Config exists, append [data] section
    cat >> "$CHEZMOI_CONFIG" <<EOF

[data]
  bw_id_rlesniak = "$BW_ID_RLESNIAK"
  bw_id_rsa_akiro = "$BW_ID_RSA_AKIRO"
EOF
  else
    # Config doesn't exist, create it
    cat > "$CHEZMOI_CONFIG" <<EOF
sourceDir = "~/workspace/dotfiles"

[data]
  bw_id_rlesniak = "$BW_ID_RLESNIAK"
  bw_id_rsa_akiro = "$BW_ID_RSA_AKIRO"
EOF
  fi
  echo "==> Saved to $CHEZMOI_CONFIG"
fi

# 6. Brew bundle — installs all packages including bitwarden-cli and fish
echo "==> Installing packages from Brewfile..."
brew bundle --file="$(chezmoi source-path)/Brewfile"

# 7. Bitwarden — unlock for SSH key retrieval
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

# 8. Apply dotfiles (includes SSH key retrieval from Bitwarden)
echo "==> Applying dotfiles..."
chezmoi apply

# 9. Set fish as default shell
FISH_PATH="$(command -v fish 2>/dev/null)"
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
fi

# 10. Fisher plugins
echo "==> Installing fish plugins..."
"$FISH_PATH" -c "fisher update" 2>/dev/null || echo "Note: fisher update failed, run manually: fisher update"

echo ""
echo "==> Bootstrap complete!"
echo ""
echo "Kolejne kroki:"
echo "  1. Klucze SSH pobrane automatycznie z Bitwarden."
echo "  2. Zaloguj się do aplikacji (Raycast, Pastebot, etc.)"
echo "  3. Uruchom terminal ponownie"
