-- Window decorations, shadows and blur
-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration

hl.config({
    decoration = {
        rounding = 15,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            new_optimizations = true,
            vibrancy = 0.1696,
        },
    },
})