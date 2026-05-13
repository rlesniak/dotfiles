# dotfiles

Personal macOS environment managed with [chezmoi](https://chezmoi.io).

| Concern | Tool |
|---|---|
| Packages (brew, cask, App Store) | Homebrew via `dot_Brewfile.tmpl` |
| macOS defaults (Dock, Finder, keyboard) | `defaults write` script |
| Dotfiles (fish, zed, git, ssh, ghostty) | chezmoi |
| SSH private keys | age-encrypted files managed by chezmoi |
| Agent tooling (`~/.agents`, `~/.opencode`) | chezmoi |

## Scope

This repo is intentionally optimized for one primary macOS setup, not for many hosts or operating systems.

Managed here:

1. macOS bootstrap and package installation
2. Shell, terminal, editor, git, ssh, and agent-tool configuration
3. Repeatable macOS defaults via `chezmoi apply`

Intentionally not managed here:

1. Machine-local hosts or IPs in `~/.ssh/config`
2. Tool-owned config rewritten outside this repo, such as OrbStack additions
3. Secure backup of the age identity used to decrypt private files

## Supported Environment

1. OS: macOS
2. Primary target: personal Mac
3. Package manager: Homebrew
4. Shell: fish

If this repo later grows to cover a laptop, work machine, or Linux host, prefer adding explicit host-specific or OS-specific `chezmoi` files instead of growing hidden one-off conditionals.

## Bootstrap On A New Mac

```bash
DOTFILES_REPO="https://github.com/your-user/dotfiles.git" bash bootstrap.sh
```

What `bootstrap.sh` actually does:

1. Checks whether Xcode Command Line Tools are installed
2. Installs them if missing, then exits so you can rerun after installation finishes
3. Installs `chezmoi` with the official installer
4. If `~/.config/chezmoi/key.txt` exists, runs `chezmoi init --apply`
5. If `~/.config/chezmoi/key.txt` does not exist, runs `chezmoi init` only and tells you to restore the age identity before `chezmoi apply`

What first `chezmoi apply` does from this repo:

1. Prompts once for `git_name` and `git_email`
2. Renders `.Brewfile` and runs `brew bundle` when `dot_Brewfile.tmpl` changes
3. Applies macOS defaults when `.chezmoiscripts/run_onchange_after_20_macos_defaults.sh` changes
4. Sets fish as the default shell on first run
5. Writes managed config files into `$HOME`

After bootstrap:

1. If needed, restore `~/.config/chezmoi/key.txt` and run `chmod 600 ~/.config/chezmoi/key.txt`
2. Run `chezmoi apply` if bootstrap initialized without applying
3. Verify SSH access with `ssh -T git@github.com`
4. Log in to your applications
5. Restart the terminal

## First-Apply Prompts

On a fresh machine, chezmoi will ask for:

1. `git_name`: used by `dot_gitconfig.tmpl`
2. `git_email`: used by `dot_gitconfig.tmpl`

That value is stored in local chezmoi config, not hardcoded into the repo.

Private files also depend on the age identity at `~/.config/chezmoi/key.txt`.

## Daily Usage

| Action | Command |
|---|---|
| Edit a dotfile | `chezmoi edit ~/.config/fish/config.fish` |
| Sync a changed file back into the repo | `chezmoi re-add ~/.config/fish/config.fish` |
| Apply dotfile changes | `chezmoi apply` |
| Add a Homebrew package | Edit `dot_Brewfile.tmpl`, then `chezmoi apply` |
| Change a macOS default | Edit `.chezmoiscripts/run_onchange_after_20_macos_defaults.sh`, then `chezmoi apply` |
| Update another machine from repo | `chezmoi update` |
| Commit and push repo changes | `chezmoi cd && git add -A && git commit -m "..." && git push` |

`chezmoi apply` automatically renders `~/.Brewfile`, runs `brew bundle` when `dot_Brewfile.tmpl` changes, and re-applies macOS defaults when the defaults script changes.

## Conditional Conventions

Use these `chezmoi` conventions when the repo grows beyond one Mac:

1. OS-specific behavior: `if eq .chezmoi.os "darwin"`
2. Host-specific behavior: `if eq .chezmoi.hostname "..."`

Current use:

1. `dot_Brewfile.tmpl` renders the package list into `~/.Brewfile`
2. `.chezmoiscripts/run_onchange_after_10_brew_bundle.sh.tmpl` applies the rendered file, not the source template

Prefer OS conditionals first. Add hostname conditionals only when a specific machine genuinely needs different configuration.

## SSH Keys With age And Chezmoi

SSH private keys are stored in this repo as age-encrypted files and restored to `~/.ssh` by chezmoi.

What is managed:

1. `~/.ssh/config`
2. `~/.ssh/id_personal`
3. `~/.ssh/id_secondary`

What you must back up separately:

1. `~/.config/chezmoi/key.txt`

Setup on another Mac:

1. Restore `~/.config/chezmoi/key.txt`
2. Run `chmod 600 ~/.config/chezmoi/key.txt`
3. Run bootstrap or `chezmoi init --apply`
4. Verify with `ssh -T git@github.com`

## Repo Structure

```text
dotfiles/
├── dot_Brewfile.tmpl                          # rendered to ~/.Brewfile for brew bundle
├── bootstrap.sh                               # one-command setup for a new Mac
├── .chezmoiscripts/
│   ├── run_onchange_after_10_brew_bundle.sh.tmpl  # runs brew bundle when dot_Brewfile.tmpl changes
│   ├── run_onchange_after_20_macos_defaults.sh    # applies macOS defaults when changed
│   └── run_once_after_40_setup_fish.sh            # sets fish as default shell once
├── dot_gitconfig.tmpl                         # ~/.gitconfig with prompted name and email
├── .chezmoi.toml.tmpl                         # local chezmoi config and first-run prompts
├── dot_config/
│   ├── private_fish/
│   │   ├── config.fish                        # fish shell config
│   │   └── fish_plugins                       # Fisher plugin list
│   ├── ghostty/config                         # Ghostty terminal config
│   └── zed/private_settings.json              # Zed settings
├── dot_ssh/
│   ├── private_config                         # SSH host aliases
│   ├── encrypted_private_id_personal.age      # age-encrypted primary SSH key
│   └── encrypted_private_id_secondary.age     # age-encrypted secondary SSH key
├── dot_agents/                                # agent skills and lock file
└── dot_opencode/opencode.json                 # OpenCode config
```
