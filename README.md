# dotfiles

Rafal's macOS configuration managed by [chezmoi](https://chezmoi.io).

| Concern | Tool |
|---|---|
| Packages (brew, cask, App Store) | Homebrew via `Brewfile` |
| macOS defaults (Dock, Finder, keyboard) | `defaults write` script |
| Dotfiles (fish, zed, git) | chezmoi |
| SSH keys | [Bitwarden SSH Agent](https://bitwarden.com/help/ssh-agent/) |

---

## Bootstrap on a new Mac

```bash
curl -fsSL https://raw.githubusercontent.com/rlesniak/dotfiles/main/bootstrap.sh | bash
```

What it does, in order:

1. Installs Xcode CLI tools
2. Installs **Homebrew**
3. Installs chezmoi via brew
4. Clones this repo via `chezmoi init`
5. Runs `chezmoi apply` — installs all brew packages, applies macOS defaults, deploys dotfiles

After bootstrap:

1. Open **Bitwarden Desktop** and log in
2. Go to **Settings → Enable SSH Agent**
3. Import/create your SSH keys in Bitwarden vault
4. Restart your terminal

---

## Daily usage

| Action | Command |
|---|---|
| Edit a dotfile | `chezmoi edit ~/.config/fish/config.fish` |
| Sync a changed file back into the repo | `chezmoi re-add ~/.config/fish/config.fish` |
| Apply dotfile changes | `chezmoi apply` |
| Add a Homebrew package | Edit `Brewfile`, then `chezmoi apply` |
| Change a macOS default | Edit `run_onchange_after_20_macos_defaults.sh`, then `chezmoi apply` |
| Push changes | `chezmoi cd && git add -A && git commit -m "..." && git push` |
| Sync on another Mac | `chezmoi update` |

> `chezmoi apply` automatically runs `brew bundle` when `Brewfile` changes and re-applies macOS defaults when the defaults script changes.

---

## SSH keys — Bitwarden SSH Agent

SSH keys are managed entirely by [Bitwarden SSH Agent](https://bitwarden.com/help/ssh-agent/). No key files on disk — Bitwarden Desktop serves them via `SSH_AUTH_SOCK`.

Setup (once per Mac):

1. Open Bitwarden Desktop → **Settings → Enable SSH Agent**
2. Create or import SSH keys in Bitwarden vault
3. Add public keys to GitHub (Settings → SSH and GPG keys)
4. Test: `ssh -T git@github.com`

Fish config sets `SSH_AUTH_SOCK` automatically.

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
│   │   ├── config.fish                    # fish shell config + SSH_AUTH_SOCK
│   │   └── fish_plugins                   # Fisher plugin list
│   ├── ghostty/config                     # Ghostty terminal config
│   └── zed/private_settings.json
│
└── dot_ssh/
    └── private_config                     # SSH host aliases (no key files needed)
```
