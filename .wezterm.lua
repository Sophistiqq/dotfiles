local wezterm = require 'wezterm'
local config = wezterm.config_builder()
config.enable_wayland = false
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 10.0
config.color_scheme = "Synthwave (Gogh)"
-- config.disable_default_key_bindings = true
local act = wezterm.action
config.hide_tab_bar_if_only_one_tab = true
config.keys = {
    { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },
}
config.default_cursor_style = "BlinkingBar"

-- change the opacity
config.enable_scroll_bar = false
config.window_padding = {
  left = ".5cell",
  right = "0cell",
  top = ".3cell",
  bottom = "0cell",
}


config.window_background_opacity = 0.90



return config
