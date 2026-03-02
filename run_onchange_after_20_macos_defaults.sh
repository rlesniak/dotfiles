#!/usr/bin/env bash
# macOS defaults — idempotent, re-applied whenever this file changes
set -euo pipefail

echo "==> Applying macOS defaults..."

###############################################################################
# Dock                                                                        #
###############################################################################

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock show-recents -bool false
# Clear all persistent app icons from Dock
defaults write com.apple.dock persistent-apps -array
# Faster Mission Control animation
defaults write com.apple.dock expose-animation-duration -float 0.1

###############################################################################
# Finder                                                                      #
###############################################################################

defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
# List view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Search current folder (not whole Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Full POSIX path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

###############################################################################
# Keyboard & text                                                             #
###############################################################################

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Key repeat: lower = faster (default 6)
defaults write NSGlobalDomain KeyRepeat -int 3
# Delay before repeat starts (default 68)
defaults write NSGlobalDomain InitialKeyRepeat -int 20
# Disable press-and-hold accent popup, enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable all smart text substitutions
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Force dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Save to disk, not iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# Instant window resize
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

###############################################################################
# Screenshots                                                                 #
###############################################################################

mkdir -p "$HOME/SS"
defaults write com.apple.screencapture location -string "$HOME/SS"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Misc                                                                        #
###############################################################################

# Disable Cmd+Space for Spotlight (use Raycast instead)
# Note: symbolic hotkeys require plist manipulation
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 \
  '<dict><key>enabled</key><false/></dict>'

# Avoid .DS_Store on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# TextEdit: plain text + UTF-8
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Suppress crash reporter dialogs
defaults write com.apple.CrashReporter DialogType -string "none"

# Time Machine: don't nag about new disks
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# AirDrop: contacts only
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"

###############################################################################
# Restart affected apps                                                       #
###############################################################################

killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "==> macOS defaults applied."
