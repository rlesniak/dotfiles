if status is-interactive
    set -gx ANDROID_HOME $HOME/Library/Android/sdk
    set -gx PATH $PATH $ANDROID_HOME/emulator
    set -gx PATH $PATH $ANDROID_HOME/platform-tools
end

# Added by Antigravity
test -d $HOME/.antigravity/antigravity/bin && fish_add_path $HOME/.antigravity/antigravity/bin

# Added by OrbStack
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
