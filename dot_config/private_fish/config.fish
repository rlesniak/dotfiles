if status is-interactive
    # Bitwarden SSH Agent (only if agent socket exists)
    if test -S $HOME/.bitwarden-ssh-agent.sock
        set -gx SSH_AUTH_SOCK $HOME/.bitwarden-ssh-agent.sock
    end

    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -gx PATH $PATH $ANDROID_HOME/emulator
    set -gx PATH $PATH $ANDROID_HOME/platform-tools
end

# Added by OrbStack
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
