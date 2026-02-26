{ config, pkgs, lib, ... }:

let
  user = "rafallesniak";
  home = "/Users/${user}";
in {
  imports = [ ./homebrew.nix ];

  ###########################################################################
  # Nix                                                                     #
  ###########################################################################

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  # Required — tracks nix-darwin state version, do not change after init
  system.stateVersion = 5;

  ###########################################################################
  # Users                                                                   #
  ###########################################################################

  users.users.${user} = {
    name = user;
    home = home;
  };

  ###########################################################################
  # Dock                                                                    #
  ###########################################################################

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.0;
    minimize-to-application = true;
    launchanim = false;
    show-recents = false;
    # Empty list = clear all persistent app icons from Dock
    persistent-apps = [];
    # Faster Mission Control animation
    expose-animation-duration = 0.1;
  };

  ###########################################################################
  # Finder                                                                  #
  ###########################################################################

  system.defaults.finder = {
    AppleShowAllFiles = true;
    ShowStatusBar = true;
    ShowPathbar = true;
    # Nlsv = list view, icnv = icon, clmv = column, glyv = gallery
    FXPreferredViewStyle = "Nlsv";
    # SCcf = search current folder (not whole Mac)
    FXDefaultSearchScope = "SCcf";
    FXEnableExtensionChangeWarning = false;
    # Show full POSIX path in title bar
    _FXShowPosixPathInTitle = true;
  };

  ###########################################################################
  # Keyboard & text                                                         #
  ###########################################################################

  system.defaults.NSGlobalDomain = {
    # Finder: show all file extensions
    AppleShowAllExtensions = true;

    # Key repeat: lower = faster (default 6)
    KeyRepeat = 3;
    # Delay before repeat starts (default 68)
    InitialKeyRepeat = 20;
    # Disable press-and-hold accent popup, enable key repeat
    ApplePressAndHoldEnabled = false;

    # Disable all smart text substitutions
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;

    # Dark mode ("Dark" = force dark, null = light, omit key = follow system)
    AppleInterfaceStyle = "Dark";

    # Always show scrollbars
    AppleShowScrollBars = "Always";

    # Default save panel targets disk, not iCloud
    NSDocumentSaveNewDocumentsToCloud = false;

    # Instant window resize animations
    NSWindowResizeTime = 1.0e-3;
  };

  ###########################################################################
  # Screenshots                                                             #
  ###########################################################################

  system.defaults.screencapture = {
    location = "${home}/SS";
    type = "png";
    disable-shadow = true;
  };

  ###########################################################################
  # Settings not yet covered by nix-darwin options                         #
  ###########################################################################

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
            # Disable 'Cmd + Space' for Spotlight Search
            "64" = {
                enabled = false;
            };
            # Disable 'Cmd + Alt + Space' for Finder search window
            "65" = {
                # Set to false to disable
                enabled = true;
            };
        };
    };

    # Avoid .DS_Store on network and USB volumes
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    # TextEdit: plain text + UTF-8 by default
    "com.apple.TextEdit" = {
      RichText = 0;
      PlainTextEncoding = 4;
      PlainTextEncodingForWrite = 4;
    };

    # Suppress crash reporter dialogs (reports still sent silently)
    "com.apple.CrashReporter" = {
      DialogType = "none";
    };

    # Time Machine: don't nag about new disks
    "com.apple.TimeMachine" = {
      DoNotOfferNewDisksForBackup = true;
    };

    # AirDrop: visible to contacts only, not everyone
    "com.apple.sharingd" = {
      DiscoverableMode = "Contacts Only";
    };
  };

  ###########################################################################
  # Activation scripts                                                      #
  ###########################################################################

  system.activationScripts.postUserActivation.text = ''
    # Create screenshot destination folder
    mkdir -p "${home}/SS"

    # Bounce Dock and Finder so all defaults take effect immediately
    /usr/bin/killall Dock    2>/dev/null || true
    /usr/bin/killall Finder  2>/dev/null || true
    /usr/bin/killall SystemUIServer 2>/dev/null || true
  '';
}
