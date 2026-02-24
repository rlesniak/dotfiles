# dotfiles

Konfiguracja macOS zarządzana przez [chezmoi](https://chezmoi.io).

## Bootstrap na nowym Macu

```bash
curl -fsSL https://raw.githubusercontent.com/rlesniak/dotfiles/main/bootstrap.sh | bash
```

## Po bootstrapie

1. Przenieś klucze SSH przez AirDrop: `~/.ssh/id_ed25519`, `~/.ssh/id_rsa_akiro`
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
