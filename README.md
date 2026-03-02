# dotfiles

Rafal's macOS configuration managed by [chezmoi](https://chezmoi.io).

| Concern | Tool |
|---|---|
| Packages (brew, cask, App Store) | Homebrew via `Brewfile` |
| macOS defaults (Dock, Finder, keyboard) | `defaults write` script |
| Dotfiles (fish, zed, SSH keys, git) | chezmoi |
| Secrets (SSH private keys) | [age](https://github.com/FiloSottile/age) encryption |

---

## Bootstrap on a new Mac

### Prerequisites

Your age private key must be stored as a Secure Note in Bitwarden. On the new Mac, copy-paste it when prompted.

### Run

```bash
curl -fsSL https://raw.githubusercontent.com/rlesniak/dotfiles/main/bootstrap.sh | bash
```

What it does, in order:

1. Installs Xcode CLI tools
2. Installs **Homebrew**
3. Installs chezmoi + age via brew
4. Prompts you to paste your **age key** (from Bitwarden) — saved to `~/.config/chezmoi/key.txt`
5. Clones this repo via `chezmoi init`
6. Runs `chezmoi apply` — installs all brew packages, applies macOS defaults, decrypts and deploys SSH keys, deploys dotfiles

After bootstrap: restart your terminal, then log in to Raycast, Arc, etc.

---

## Daily usage

| Action | Command |
|---|---|
| Edit a dotfile | `chezmoi edit ~/.config/fish/config.fish` |
| Sync a changed file back into the repo | `chezmoi re-add ~/.config/fish/config.fish` |
| Apply dotfile changes | `chezmoi apply` |
| Add a Homebrew package | Edit `Brewfile`, then `chezmoi apply` |
| Change a macOS default | Edit `run_onchange_after_20_macos_defaults.sh`, then `chezmoi apply` |
| Add an encrypted file | `chezmoi add --encrypt ~/.ssh/id_new_key` |
| Push changes | `chezmoi cd && git add -A && git commit -m "..." && git push` |
| Sync on another Mac | `chezmoi update` |

> `chezmoi apply` automatically runs `brew bundle` when `Brewfile` changes and re-applies macOS defaults when the defaults script changes.

---

## Secrets — age encryption

SSH private keys are encrypted with [age](https://github.com/FiloSottile/age) and stored directly in the repo. chezmoi decrypts them automatically on `chezmoi apply`.

**age key** (`~/.config/chezmoi/key.txt`) is stored as a Secure Note in Bitwarden — copy it manually on a new Mac during bootstrap.

### One-time setup (already done)

```bash
# Generate age keypair
age-keygen -o ~/.config/chezmoi/key.txt

# Save the public key (age1...) — needed for .chezmoi.toml.tmpl recipient field
cat ~/.config/chezmoi/key.txt | grep "public key"

# Add SSH keys as encrypted files
chezmoi add --encrypt ~/.ssh/id_rlesniak
chezmoi add --encrypt ~/.ssh/id_rsa_akiro

# Save ~/.config/chezmoi/key.txt as a Secure Note in Bitwarden
```

---

## Repo structure

```
dotfiles/
├── Brewfile                               # all Homebrew packages (brew, cask, mas)
├── bootstrap.sh                           # one-command setup for a new Mac
│
├── run_onchange_after_10_brew_bundle.sh.tmpl  # runs brew bundle when Brewfile changes
├── run_onchange_after_20_macos_defaults.sh    # applies macOS defaults when script changes
├── run_once_after_40_setup_fish.sh            # sets fish as default shell (runs once)
│
├── dot_gitconfig.tmpl                     # ~/.gitconfig (email injected from chezmoi)
│
├── dot_config/
│   ├── private_fish/
│   │   ├── config.fish                    # fish shell config
│   │   └── fish_plugins                   # Fisher plugin list
│   ├── ghostty/config                     # Ghostty terminal config
│   └── zed/private_settings.json
│
└── dot_ssh/
    ├── private_config                     # SSH host aliases
    ├── encrypted_private_id_rlesniak.age  # age-encrypted SSH key (personal)
    └── encrypted_private_id_rsa_akiro.age # age-encrypted SSH key (company)
```
