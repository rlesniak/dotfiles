{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      # Remove packages no longer listed here
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "tw93/tap"
    ];

    brews = [
      "bat"
      "bitwarden-cli"
      "coreutils"
      "ffmpeg"
      "fish"
      "fisher"
      "fzf"
      "gh"
      "git"
      "mas"
      "watchman"
      "tw93/tap/mole"
      "tw93/tap/snitch"
    ];

    casks = [
      "arc"
      "bambu-studio"
      "font-monaspace"
      "font-source-code-pro"
      "font-source-code-pro-for-powerline"
      "ghostty"
      "github"
      "orbstack"
      "raycast"
      "stats"
      "tailscale-app"
      "the-unarchiver"
      "visual-studio-code"
      "yaak"
      "zed"
      "zen"
      "zulu@17"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
  };
}