-- Monitor configuration
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Keep the virtual streaming display (HDMI-A-1) off in the normal desktop session.
-- It is only used by the "Sunshine Streaming" session (config/hypr/streaming.conf).
hl.monitor({
    output   = "HDMI-A-1",
    disabled = true,
})

hl.monitor({
    output   = "", -- all monitors
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})