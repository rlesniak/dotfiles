# dotfiles

Konfiguracja macOS zarządzana przez [chezmoi](https://chezmoi.io).

## Bootstrap na nowym Macu

```bash
curl -fsSL https://raw.githubusercontent.com/rlesniak/dotfiles/main/bootstrap.sh | bash
```

Skrypt automatycznie pyta o Bitwarden master password i pobiera klucze SSH.

## Bitwarden — SSH keys

Klucze SSH przechowywane jako Secure Notes w Bitwarden:
- `SSH Key: id_ed25519` — klucz prywatny dla osobistego GitHub
- `SSH Key: id_rsa_akiro` — klucz prywatny dla firmowego GitHub

Klucze zapisywane do `~/.ssh/` z permissions 0600 podczas `chezmoi apply`.

Aby ręcznie odświeżyć klucze:

```bash
export BW_SESSION="$(bw unlock --raw)"
chezmoi apply ~/.ssh/id_ed25519 ~/.ssh/id_rsa_akiro
```

## Po bootstrapie

1. Klucze SSH pobrane automatycznie z Bitwarden.
2. Uruchom fish i zainstaluj pluginy: `fisher update`
3. Zaloguj się do aplikacji (Raycast, Pastebot, 1Password, etc.)

## Codzienne użycie

| Akcja | Komenda |
|-------|---------|
| Edycja pliku | `chezmoi edit ~/.config/fish/config.fish` |
| Sync zmian z dysku | `chezmoi re-add ~/.config/fish/config.fish` |
| Commit | `chezmoi cd && git add -A && git commit -m "..." && git push` |
| Sync na innym Macu | `chezmoi update` |

## Struktura repo

```
dotfiles/
├── Brewfile              # Homebrew packages
├── bootstrap.sh          # Instalacja na nowym Macu
└── dot_config/
    ├── fish/             # Fish shell config
    ├── vscode/           # VS Code settings + extensions list
    └── zed/              # Zed settings
```
