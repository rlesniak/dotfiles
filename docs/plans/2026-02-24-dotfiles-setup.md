# Dotfiles Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Zbudować kompletne repozytorium dotfiles oparte o chezmoi, Brewfile i bootstrap.sh, które pozwoli odtworzyć całe środowisko macOS jedną komendą.

**Architecture:** Chezmoi zarządza plikami konfiguracyjnymi przez symlinki/kopie z `~/.local/share/chezmoi` (wskazującego na `~/workspace/dotfiles/home/`). Brewfile deklaruje wszystkie pakiety Homebrew. `bootstrap.sh` orkestruje całą instalację od zera na nowym Macu.

**Tech Stack:** chezmoi, Homebrew Bundle, fish shell, Fisher, git

---

### Task 1: Inicjalizacja repozytorium git i chezmoi

**Files:**
- Create: `~/workspace/dotfiles/.gitignore`
- Create: `~/workspace/dotfiles/.chezmoi.toml.tmpl` (chezmoi config)

**Step 1: Zainicjalizuj git repo**

```bash
cd ~/workspace/dotfiles
git init
git branch -M main
```

**Step 2: Stwórz .gitignore**

```
.DS_Store
*.swp
```

**Step 3: Zainicjalizuj chezmoi wskazując na to repo**

```bash
chezmoi init --source ~/workspace/dotfiles
```

Chezmoi stworzy `~/.config/chezmoi/chezmoi.toml` wskazujący na `~/workspace/dotfiles`.

**Step 4: Sprawdź że działa**

```bash
chezmoi status
```
Oczekiwany output: pusta lista (nic jeszcze nie dodano)

**Step 5: Commit**

```bash
cd ~/workspace/dotfiles
git add .gitignore
git commit -m "chore: init repo"
```

---

### Task 2: Fish shell — config.fish

**Files:**
- Create: `~/workspace/dotfiles/home/dot_config/fish/config.fish`

**Step 1: Stwórz katalog**

```bash
mkdir -p ~/workspace/dotfiles/home/dot_config/fish
```

**Step 2: Dodaj config.fish**

Zawartość pliku (OrbStack i Antigravity są instalowane przez bootstrap, więc zostawiamy):

```fish
if status is-interactive
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -gx PATH $PATH $ANDROID_HOME/emulator
    set -gx PATH $PATH $ANDROID_HOME/platform-tools
end

# Added by Antigravity
fish_add_path /Users/rafal/.antigravity/antigravity/bin

# Added by OrbStack
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
```

**Step 3: Dodaj fish_plugins (Fisher plugin list)**

Plik `~/workspace/dotfiles/home/dot_config/fish/fish_plugins`:

```
patrickf1/fzf.fish
jorgebucaran/fisher
pure-fish/pure
```

**Step 4: Powiedz chezmoi żeby śledził te pliki**

```bash
chezmoi add ~/.config/fish/config.fish
chezmoi add ~/.config/fish/fish_plugins
```

Alternatywnie pliki już są w `home/dot_config/fish/` — chezmoi mapuje `dot_` na `.` automatycznie.

**Step 5: Sprawdź że chezmoi widzi pliki poprawnie**

```bash
chezmoi status
```
Powinny pojawić się wpisy dla `~/.config/fish/config.fish` i `~/.config/fish/fish_plugins`.

**Step 6: Commit**

```bash
cd ~/workspace/dotfiles
git add home/dot_config/fish/
git commit -m "feat: add fish shell config and plugins"
```

---

### Task 3: Fish shell — conf.d (inicjalizacja pluginów)

**Files:**
- Create: `~/workspace/dotfiles/home/dot_config/fish/conf.d/` (kilka plików)

Pliki w `conf.d/` są generowane przez Fisher po instalacji pluginów — **nie kopiujemy ich ręcznie**. Fisher sam je stworzy po uruchomieniu `fisher update` na nowym Macu.

**Step 1: Dodaj notatkę w README**

Stwórz `~/workspace/dotfiles/README.md`:

```markdown
# dotfiles

Konfiguracja macOS zarządzana przez chezmoi.

## Bootstrap na nowym Macu

```bash
curl -fsSL https://raw.githubusercontent.com/rafalles/dotfiles/main/bootstrap.sh | bash
```

## Po bootstrapie

1. Przenieś klucze SSH przez AirDrop: `~/.ssh/id_ed25519`, `~/.ssh/id_rsa_akiro`
2. Uruchom fish i zainstaluj pluginy: `fisher update`
3. Zaloguj się do aplikacji

## Codzienne użycie

- Edycja pliku: `chezmoi edit ~/.config/fish/config.fish`
- Sync zmian z dysku: `chezmoi re-add ~/.config/fish/config.fish`
- Commit: `chezmoi cd && git add -A && git commit -m "..." && git push`
- Sync na innym Macu: `chezmoi update`
```

**Step 2: Commit**

```bash
cd ~/workspace/dotfiles
git add README.md
git commit -m "docs: add README with bootstrap instructions"
```

---

### Task 4: Git config

**Files:**
- Create: `~/workspace/dotfiles/home/dot_gitconfig`

**Step 1: Stwórz dot_gitconfig**

```ini
[user]
	email = rafallesniak24@gmail.com
	name = Rafal Lesniak
```

**Step 2: Sprawdź że chezmoi mapuje poprawnie**

```bash
chezmoi diff
```
Nie powinno być różnicy między repo a `~/.gitconfig`.

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add home/dot_gitconfig
git commit -m "feat: add gitconfig"
```

---

### Task 5: SSH config (bez kluczy)

**Files:**
- Create: `~/workspace/dotfiles/home/dot_ssh/config`

**Step 1: Stwórz dot_ssh/config**

```
# Personal GitHub Account
Host private
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# Company GitHub Account
Host akiro
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_akiro
    IdentitiesOnly yes

# GitHub via port 443 (if port 22 is blocked)
Host github.com
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Uwaga: **pomijamy** blok `Include ~/.orbstack/ssh/config` i VPS IP — OrbStack doda go sam po instalacji, VPS IP jest specyficzne dla środowiska.

**Step 2: Ustaw permissions w chezmoi**

Stwórz `~/workspace/dotfiles/home/dot_ssh/.chezmoiattr`:
```
config perm:0600
```

Albo nazwij plik `private_config` zamiast `config` — chezmoi ustawia wtedy `0600` automatycznie.

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add home/dot_ssh/
git commit -m "feat: add ssh config"
```

---

### Task 6: VS Code settings i extensions

**Files:**
- Create: `~/workspace/dotfiles/home/dot_config/vscode/settings.json`
- Create: `~/workspace/dotfiles/home/dot_config/vscode/extensions.txt`

Uwaga: VSCode na macOS trzyma config w `~/Library/Application Support/Code/User/` — chezmoi nie obsługuje `Library/` bezpośrednio. Zamiast tego trzymamy pliki w repo i bootstrap/skrypt kopiuje je na miejsce. Alternatywnie użyj `run_once_` skryptu w chezmoi.

**Step 1: Stwórz katalog**

```bash
mkdir -p ~/workspace/dotfiles/home/dot_config/vscode
```

**Step 2: Stwórz settings.json**

Skopiuj zawartość z `~/Library/Application Support/Code/User/settings.json` do `~/workspace/dotfiles/home/dot_config/vscode/settings.json`.

**Step 3: Stwórz extensions.txt**

```
anthropic.claude-code
biomejs.biome
bradlc.vscode-tailwindcss
catppuccin.catppuccin-vsc
catppuccin.catppuccin-vsc-icons
coderabbit.coderabbit-vscode
dbaeumer.vscode-eslint
eamodio.gitlens
esbenp.prettier-vscode
github.copilot-chat
jhasse.bracket-select2
mechatroner.rainbow-csv
meganrogge.template-string-converter
ms-vscode.vscode-speech
redhat.vscode-yaml
streetsidesoftware.code-spell-checker
upstash.context7-mcp
vitest.explorer
wmaurer.change-case
yoavbls.pretty-ts-errors
yzhang.markdown-all-in-one
```

**Step 4: Stwórz chezmoi run_once skrypt instalujący VSCode settings**

Plik `~/workspace/dotfiles/home/run_once_after_vscode.sh.tmpl`:

```bash
#!/bin/bash
set -e
VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER"
cp "{{ .chezmoi.sourceDir }}/dot_config/vscode/settings.json" "$VSCODE_USER/settings.json"

# Install extensions
while IFS= read -r ext; do
  code --install-extension "$ext" --force 2>/dev/null || true
done < "{{ .chezmoi.sourceDir }}/dot_config/vscode/extensions.txt"
```

**Step 5: Commit**

```bash
cd ~/workspace/dotfiles
git add home/dot_config/vscode/ home/run_once_after_vscode.sh.tmpl
git commit -m "feat: add vscode settings and extensions"
```

---

### Task 7: Zed settings

**Files:**
- Create: `~/workspace/dotfiles/home/dot_config/zed/settings.json`

**Step 1: Dodaj chezmoi**

```bash
chezmoi add ~/.config/zed/settings.json
```

To automatycznie stworzy `~/workspace/dotfiles/home/dot_config/zed/settings.json`.

**Step 2: Sprawdź**

```bash
chezmoi diff
```
Brak różnic.

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add home/dot_config/zed/
git commit -m "feat: add zed settings"
```

---

### Task 8: Brewfile

**Files:**
- Create: `~/workspace/dotfiles/Brewfile`

**Step 1: Stwórz Brewfile**

```ruby
# Taps (custom)
tap "jnsahaj/lumen"
tap "mobile-dev-inc/tap"
tap "tw93/tap"

# CLI tools
brew "bat"
brew "coreutils"
brew "ffmpeg"
brew "fish"
brew "fisher"
brew "fzf"
brew "gh"
brew "git"
brew "gping"
brew "grep"
brew "httpie"
brew "mas"
brew "node"
brew "python@3.10"
brew "watchman"

# Mobile dev
brew "cocoapods"
brew "fastlane"
brew "mobile-dev-inc/tap/maestro"

# Custom taps
brew "jnsahaj/lumen/lumen"
brew "tw93/tap/mole"
brew "snitch"

# Casks — aplikacje
cask "arc"
cask "autodesk-fusion"
cask "bambu-studio"
cask "brave-browser"
cask "font-lato"
cask "font-open-sans"
cask "font-roboto"
cask "font-source-code-pro"
cask "font-source-code-pro-for-powerline"
cask "ghostty"
cask "github"
cask "google-chrome"
cask "httpie-desktop"
cask "imageoptim"
cask "orbstack"
cask "pastebot"
cask "qlmarkdown"
cask "quicklook-json"
cask "raindropio"
cask "raycast"
cask "reflex"
cask "stats"
cask "tailscale"
cask "the-unarchiver"
cask "tinkerwell"
cask "transmit"
cask "tunnelbear"
cask "tuple"
cask "visual-studio-code"
cask "yaak"
cask "zed"
cask "zen-browser"
cask "zulu@17"

# Mac App Store
mas "Xcode", id: 497799835
```

**Step 2: Zweryfikuj że Brewfile zgadza się z tym co masz**

```bash
brew bundle check --file=~/workspace/dotfiles/Brewfile
```

Może wyświetlić brakujące lub nadmiarowe pakiety — to ok na tym etapie.

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add Brewfile
git commit -m "feat: add Brewfile"
```

---

### Task 9: bootstrap.sh

**Files:**
- Create: `~/workspace/dotfiles/bootstrap.sh`

**Step 1: Stwórz bootstrap.sh**

```bash
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
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. chezmoi
if ! command -v chezmoi &>/dev/null; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

# 4. Clone dotfiles i apply
echo "==> Applying dotfiles..."
chezmoi init --apply https://github.com/rafalles/dotfiles.git

# 5. Brew bundle
echo "==> Installing packages from Brewfile..."
brew bundle --file="$(chezmoi source-path)/Brewfile"

# 6. Set fish as default shell
if ! grep -q "$(which fish)" /etc/shells; then
  echo "==> Adding fish to /etc/shells..."
  echo "$(which fish)" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$(which fish)" ]; then
  echo "==> Setting fish as default shell..."
  chsh -s "$(which fish)"
fi

# 7. Fisher plugins
echo "==> Installing fish plugins..."
fish -c "fisher update"

echo ""
echo "==> Bootstrap complete!"
echo ""
echo "Kolejne kroki:"
echo "  1. Przenieś klucze SSH przez AirDrop: ~/.ssh/id_ed25519 i ~/.ssh/id_rsa_akiro"
echo "  2. Zaloguj się do aplikacji (Raycast, Pastebot, etc.)"
echo "  3. Uruchom terminal ponownie"
```

**Step 2: Nadaj uprawnienia wykonywania**

```bash
chmod +x ~/workspace/dotfiles/bootstrap.sh
```

**Step 3: Commit**

```bash
cd ~/workspace/dotfiles
git add bootstrap.sh
git commit -m "feat: add bootstrap script"
```

---

### Task 10: GitHub remote i push

**Step 1: Stwórz repo na GitHubie**

```bash
gh repo create dotfiles --public --source=~/workspace/dotfiles --remote=origin --push
```

To jednolinijkowo tworzy repo, ustawia remote i pushuje.

**Step 2: Zweryfikuj**

```bash
cd ~/workspace/dotfiles
git log --oneline
git remote -v
```

**Step 3: Sprawdź że bootstrap URL w skrypcie zgadza się z repo**

W `bootstrap.sh` zmień URL jeśli GitHub username jest inny niż `rafalles`:
```
chezmoi init --apply https://github.com/<TWOJ_USERNAME>/dotfiles.git
```

---

### Task 11: Weryfikacja końcowa

**Step 1: Sprawdź strukturę repo**

```bash
find ~/workspace/dotfiles -not -path '*/\.*' -not -path '*/docs/*' | sort
```

Oczekiwana struktura:
```
dotfiles/
├── Brewfile
├── README.md
├── bootstrap.sh
├── docs/plans/2026-02-24-dotfiles-setup.md
└── home/
    ├── dot_config/
    │   ├── fish/
    │   │   ├── config.fish
    │   │   └── fish_plugins
    │   ├── vscode/
    │   │   ├── settings.json
    │   │   └── extensions.txt
    │   └── zed/
    │       └── settings.json
    ├── dot_gitconfig
    ├── dot_ssh/
    │   └── private_config
    └── run_once_after_vscode.sh.tmpl
```

**Step 2: Sprawdź chezmoi diff**

```bash
chezmoi diff
```

Nie powinno być różnic dla zarządzanych plików.

**Step 3: Symulacja apply (dry-run)**

```bash
chezmoi apply --dry-run --verbose
```

Powinno pokazać co by zrobiło bez wprowadzania zmian.
