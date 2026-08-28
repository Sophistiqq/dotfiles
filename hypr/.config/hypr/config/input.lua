-- Keyboard and mouse input
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        numlock_by_default = true,

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Per-device input configs
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})