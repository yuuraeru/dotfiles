require "config.monitors"
require "config.autostart"
require "config.env"
require "config.keybindings"
require "config.animations"
require "config.rules"
require "config.gestures"

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config {
    general = {
        gaps_in = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border = "rgba(f5c2e7aa)",
            inactive_border = "rgba(313244aa)",
        },

        resize_on_border = false,
        allow_tearing = false,

        layout = "scrolling",
    },

    decoration = {
        rounding = 12,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 3,
            vibrancy = 0.1696,
            ignore_opacity = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        middle_click_paste = false,
    },

    input = {
        kb_layout = "us",

        follow_mouse = 1,

        sensitivity = -0.75,
        accel_profile = "flat",

        repeat_rate = 35,
        repeat_delay = 200,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
        },
    },
}

hl.device {
    name = "asuf1203:00-2808:0217-touchpad",
    sensitivity = 0,
}
