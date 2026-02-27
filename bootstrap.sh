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
# 2. Nix (Determinate Systems installer — enables flakes by default)         #
###############################################################################

if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
fi

# Source nix into the current shell session
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

###############################################################################
# 3. Homebrew (nix-darwin's homebrew module manages packages, not brew itself)#
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
# 4. chezmoi                                                                  #
###############################################################################

if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

###############################################################################
# 5. Bitwarden CLI (needed BEFORE chezmoi apply — SSH key templates use it)  #
###############################################################################

if ! command -v bw &>/dev/null; then
  echo "==> Installing Bitwarden CLI..."
  brew install bitwarden-cli
fi

###############################################################################
# 6. Bitwarden unlock                                                         #
###############################################################################

BW_STATUS="$(bw status 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unauthenticated'))" \
  2>/dev/null || echo "unauthenticated")"

if [[ "$BW_STATUS" == "unauthenticated" ]]; then
  echo "==> Logging into Bitwarden..."
  bw login
  export BW_SESSION="$(bw unlock --raw)"
elif [[ "$BW_STATUS" == "locked" ]]; then
  echo "==> Unlocking Bitwarden..."
  export BW_SESSION="$(bw unlock --raw)"
else
  echo "==> Bitwarden already unlocked."
fi

###############################################################################
# 7. Clone dotfiles repo (without applying yet — nix-darwin needs the flake) #
###############################################################################

echo "==> Cloning dotfiles..."
# init without --apply: clones repo + writes chezmoi.toml, does not touch $HOME
chezmoi init https://github.com/rlesniak/dotfiles.git

CHEZMOI_SOURCE="$(chezmoi source-path)"

###############################################################################
# 8. Bootstrap nix-darwin                                                     #
#    First run uses `nix run` because darwin-rebuild doesn't exist yet.       #
#    This also installs all Homebrew packages declared in nix/homebrew.nix.   #
###############################################################################

echo "==> Bootstrapping nix-darwin (this will take a few minutes)..."
nix run github:LnL7/nix-darwin -- switch --flake "${CHEZMOI_SOURCE}#macbook"

###############################################################################
# 9. Apply chezmoi dotfiles                                                   #
#    darwin-rebuild is now in PATH; homebrew packages are installed.          #
###############################################################################

echo "==> Applying dotfiles..."
chezmoi apply

echo ""
echo "==> Bootstrap complete!"
echo "  1. SSH keys downloaded automatically from Bitwarden."
echo "  2. Log in to your applications (Raycast, etc.)"
echo "  3. Restart your terminal"