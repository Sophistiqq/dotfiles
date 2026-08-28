-- User programs
-- Shared with other config files via require()

local programs = {
    terminal = "alacritty",
    fileManager = "nautilus",
    browser = "chromium",
    menu = "qs ipc -p /home/roi/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml call drawers toggle launcher",
    mainMod = "SUPER",
}

return programs