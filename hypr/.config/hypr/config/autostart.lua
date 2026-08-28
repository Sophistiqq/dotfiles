-- Autostart processes
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("quickshell -p /home/roi/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 14")
end)