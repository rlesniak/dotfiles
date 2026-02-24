# macOS Defaults Script Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Stworzyć `run_once_after_macos.sh` który automatycznie konfiguruje macOS defaults podczas bootstrap.

**Architecture:** Jeden skrypt bash z `defaults write` komendami pogrupowanymi w sekcje. chezmoi uruchamia go raz (`run_once_`) po `chezmoi apply`. Na końcu skrypt restartuje Dock i Finder żeby zmiany weszły w życie bez restartu systemu.

**Tech Stack:** bash, macOS `defaults`, `socketfilterfw`

---

### Task 1: Stwórz `run_once_after_macos.sh`

**Files:**
- Create: `~/workspace/dotfiles/run_once_after_macos.sh`

**Step 1: Stwórz plik**

```bash
#!/bin/bash
# macOS defaults — applied once during bootstrap via chezmoi
# To re-apply manually: bash run_once_after_macos.sh

set -e

echo "==> Applying macOS defaults..."

###############################################################################
# Dock                                                                        #
###############################################################################

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Remove auto-hide animation
defaults write com.apple.dock autohide-time-modifier -float 0

# Minimize windows into their application's icon
defaults write com.apple.dock minimize-to-application -bool true

# Disable launch animation
defaults write com.apple.dock launchanim -bool false

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Use list view in all Finder windows
# Four-letter codes for views: icnv (icon), Nlsv (list), clmv (column), glyv (gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Set fast key repeat rate (lower = faster; default is 6)
defaults write NSGlobalDomain KeyRepeat -int 3

# Set short delay before key repeat starts (default is 68)
defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Disable press-and-hold for accent menu — enables key repeat instead
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

###############################################################################
# System UI                                                                   #
###############################################################################

# Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Auto-switch dark/light based on time of day
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Speed up window resize animations
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

###############################################################################
# Screenshots                                                                 #
###############################################################################

# Save screenshots to ~/SS
mkdir -p "$HOME/SS"
defaults write com.apple.screencapture location -string "$HOME/SS"

# Save screenshots as PNG
defaults write com.apple.screencapture type -string "png"

###############################################################################
# Privacy / UX                                                                #
###############################################################################

# Avoid creating .DS_Store files on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Don't offer new disks for Time Machine backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Default save to disk (not iCloud)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Use plain text mode by default
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Crash Reporter                                                              #
###############################################################################

# Disable crash reporter dialogs (reports still sent silently)
defaults write com.apple.CrashReporter DialogType -string "none"

###############################################################################
# AirDrop                                                                     #
###############################################################################

# Limit AirDrop to contacts only (not "Everyone")
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"

###############################################################################
# Apply changes                                                               #
###############################################################################

echo "==> Restarting Dock and Finder..."
killall Dock
killall Finder

echo "==> macOS defaults applied successfully."
```

**Step 2: Ustaw executable**

```bash
chmod +x ~/workspace/dotfiles/run_once_after_macos.sh
```

**Step 3: Zweryfikuj składnię**

```bash
bash -n ~/workspace/dotfiles/run_once_after_macos.sh
```

Oczekiwany output: brak błędów.

**Step 4: Testowo uruchom skrypt**

```bash
bash ~/workspace/dotfiles/run_once_after_macos.sh
```

Oczekiwany output:
```
==> Applying macOS defaults...
==> Restarting Dock and Finder...
==> macOS defaults applied successfully.
```

Dock i Finder powinny się zrestartować (Finder może zniknąć na chwilę z menu bar).

**Step 5: Zweryfikuj kilka kluczowych ustawień**

```bash
defaults read com.apple.dock autohide
# oczekiwane: 1

defaults read com.apple.finder AppleShowAllFiles
# oczekiwane: 1

defaults read NSGlobalDomain ApplePressAndHoldEnabled
# oczekiwane: 0

defaults read com.apple.screencapture location
# oczekiwane: /Users/rafal/SS
```

**Step 6: Commit i push**

```bash
cd ~/workspace/dotfiles
git add run_once_after_macos.sh
git commit -m "feat: add macos defaults script"
git push
```

---

### Task 2: Zaktualizuj README

**Files:**
- Modify: `~/workspace/dotfiles/README.md`

**Step 1: Dodaj wiersz do tabeli "Codzienne użycie"**

Znajdź tabelę z akcjami i dodaj wiersz:

```markdown
| Ponów macOS defaults | `bash run_once_after_macos.sh` |
```

**Step 2: Zaktualizuj sekcję "Struktura repo"**

Dodaj `run_once_after_macos.sh` do listy plików:

```
├── run_once_after_macos.sh  # macOS system defaults
```

**Step 3: Commit i push**

```bash
cd ~/workspace/dotfiles
git add README.md
git commit -m "docs: add macos defaults script to README"
git push
```
