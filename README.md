# dotfiles

Rafal's macOS configuration managed by [chezmoi](https://chezmoi.io) + [nix-darwin](https://github.com/LnL7/nix-darwin).

| Concern | Tool |
|---|---|
| System defaults + Homebrew packages | nix-darwin (`nix/darwin.nix`, `nix/homebrew.nix`) |
| Dotfiles (fish, zed, vscode, SSH keys) | chezmoi |
| Secrets (SSH private keys) | Bitwarden via `bw` CLI |

---

## Bootstrap on a new Mac

```bash
curl -fsSL https://raw.githubusercontent.com/rlesniak/dotfiles/main/bootstrap.sh | bash
```

What it does, in order:

1. Installs Xcode CLI tools
2. Installs **Nix** (Determinate Systems installer — flakes enabled by default)
3. Installs **Homebrew** (nix-darwin manages packages, but `brew` itself must exist)
4. Installs chezmoi + Bitwarden CLI via brew
5. Unlocks Bitwarden (prompts for master password)
6. Clones this repo via `chezmoi init`
7. Runs `nix-darwin` for the first time — applies all system defaults and installs all Homebrew packages
8. Runs `chezmoi apply` — deploys dotfiles and downloads SSH keys from Bitwarden

After bootstrap: restart your terminal, then log in to Raycast, Arc, etc.

---

## Daily usage

| Action | Command |
|---|---|
| Edit a dotfile | `chezmoi edit ~/.config/fish/config.fish` |
| Sync a changed file back into the repo | `chezmoi re-add ~/.config/fish/config.fish` |
| Apply dotfile changes | `chezmoi apply` |
| Add a Homebrew package | Edit `nix/homebrew.nix`, then `chezmoi apply` |
| Change a macOS default | Edit `nix/darwin.nix`, then `chezmoi apply` |
| Rebuild nix-darwin manually | `darwin-rebuild switch --flake $(chezmoi source-path)#macbook` |
| Push changes | `chezmoi cd && git add -A && git commit -m "..." && git push` |
| Sync on another Mac | `chezmoi update` |

> `chezmoi apply` automatically triggers `darwin-rebuild switch` whenever any file inside `nix/` or `flake.nix` changes (tracked by `run_onchange_after_30_darwin_rebuild.sh.tmpl`).

---

## Bitwarden — SSH keys

SSH private keys are stored as Secure Notes in Bitwarden:

- `SSH Key: id_rlesniak` — personal GitHub
- `SSH Key: id_rsa_akiro` — company GitHub

During bootstrap, the script unlocks Bitwarden and `chezmoi apply` pulls the key contents via `bw get notes <id>`. Keys are written to `~/.ssh/` with `0600` permissions.

To manually refresh keys:

```bash
export BW_SESSION="$(bw unlock --raw)"
chezmoi apply ~/.ssh/id_rlesniak ~/.ssh/id_rsa_akiro
```

---

## Repo structure

```
dotfiles/
├── flake.nix                              # nix-darwin entry point
├── flake.lock                             # pinned nix dependency versions
├── nix/
│   ├── darwin.nix                         # macOS defaults + activation scripts
│   └── homebrew.nix                       # all Homebrew packages (replaces Brewfile)
│
├── bootstrap.sh                           # one-command setup for a new Mac
│
├── run_onchange_after_30_darwin_rebuild.sh.tmpl  # triggers darwin-rebuild on nix changes
├── run_once_after_40_setup_fish.sh        # sets fish as default shell (runs once)
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
    ├── private_id_rlesniak.tmpl           # pulled from Bitwarden at apply time
    └── private_id_rsa_akiro.tmpl          # pulled from Bitwarden at apply time
```

---

## Updating nix-darwin

```bash
# Update flake inputs (nixpkgs, nix-darwin) to latest
darwin-rebuild switch --flake $(chezmoi source-path)#macbook --recreate-lock-file

# Or just bump a specific input
nix flake update nixpkgs --flake $(chezmoi source-path)
darwin-rebuild switch --flake $(chezmoi source-path)#macbook
```

Commit `flake.lock` after updating to pin the new versions.
