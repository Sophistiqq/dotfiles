-- Keybindings
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local programs = require("config/programs")
local mainMod = programs.mainMod
local terminal = programs.terminal
local browser = programs.browser
local fileManager = programs.fileManager
local menu = programs.menu

-- Launch
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))

-- Open launcher prefilled with configs picker
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("qs ipc -p /home/roi/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml call launcher openConfigs"))

-- Quickshell (Caelestia shell) restart
local quickshellRestart = [[pkill quickshell; (export QML_IMPORT_PATH=/home/roi/.local/usr/lib/qt6/qml; export CAELESTIA_LIB_DIR=/home/roi/.local/usr/lib/qt6/qml/Caelestia; quickshell -p /home/roi/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml &)]]
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(quickshellRestart))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(quickshellRestart))

-- Windows
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Lock & screenshots
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qs ipc -p /home/roi/dotfiles/quickshell/.config/quickshell/caelestia/shell.qml call lock lock"))
hl.bind("PRINT", hl.dsp.exec_cmd("caelestia screenshot"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.global("caelestia:screenshotFreezeClip"))
hl.bind(mainMod .. " + CTRL + PRINT", hl.dsp.global("caelestia:screenshot"))

-- Quit
hl.bind(mainMod .. " + M", hl.dsp.exit())

-- Quick web shortcuts
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(browser .. " https://www.facebook.com"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(browser .. " https://www.gmail.com"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(browser .. " http://10.0.23.245:3000/swagger"))

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Scrolling layout navigation
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + apostrophe", hl.dsp.layout("fit_into_view"))
hl.bind(mainMod .. " + SHIFT + apostrophe", hl.dsp.layout("inhibit_scroll"))

-- Workspaces
-- Move window to workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys (volume & brightness)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true, locked = true })

-- Media keys (player control)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })