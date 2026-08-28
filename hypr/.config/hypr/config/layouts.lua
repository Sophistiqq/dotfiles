-- Default layout is now scrolling
-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/

hl.config({
    scrolling = {
        direction = "right",
        column_width = 0.5,
        fullscreen_on_one_column = true,
        wrap_focus = true,
    },
})

-- master layout settings (used when switching layouts)
-- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})