if status is-interactive
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -gx PATH $PATH $ANDROID_HOME/emulator
    set -gx PATH $PATH $ANDROID_HOME/platform-tools
end

# Added by OrbStack
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
