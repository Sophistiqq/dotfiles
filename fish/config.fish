if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx EDITOR /usr/bin/nvim
set -u fish_greeting ""

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

set -gx ANDROID_HOME /opt/android-sdk/
# platform-tools like adb
set -gx PATH /opt/android-sdk/platform-tools $PATH
set -gx ANDROID_SDK_ROOT /opt/android-sdk/platform-tools
