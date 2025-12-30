if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx EDITOR /usr/bin/nvim
set -u fish_greeting ""

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

set -gx ANDROID_HOME "/home/roi/Android/Sdk"
# set it to path
# set -gx ANDROID_SDK_ROOT "/home/roi/Android/Sdk/cmdline-tools/latest/bin"
set -gx ANDROID_SDK_ROOT "/home/roi/Android/Sdk/cmdline-tools/latest"
# put it to path
set -gx PATH $ANDROID_SDK_ROOT $ANDROID_SDK_ROOT/platform-tools $ANDROID_SDK_ROOT/emulator $PATH

fish_add_path /home/roi/.spicetify

# Created by `pipx` on 2025-11-17 08:51:26
set PATH $PATH /home/roi/.local/bin


set -gx DOTNET_ROOT "/usr/share/dotnet/"
# Tools
set -gx PATH "$DOTNET_ROOT/tools" "$PATH"
