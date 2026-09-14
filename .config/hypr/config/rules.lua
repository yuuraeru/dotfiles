--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Windows

hl.window_rule {
    name = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
}

hl.window_rule {
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },

    no_focus = true,
}

hl.window_rule {
    name = "discord",
    match = { class = "discord" },
    workspace = "1 silent",
}

--[[ hl.window_rule {
	name = "maximize-window",
	match = { class = "librewolf|discord|com.obsproject.Studio" },
	maximize = true,
} ]]

hl.window_rule {
    name = "fullscreen-window",
    match = { class = "Waydroid" },
    fullscreen = true,
}

-- Layers

hl.layer_rule {
    name = "blur-layer",
    match = { namespace = "^qs_.*$" },
    blur = true,
    ignore_alpha = 0,
}

hl.layer_rule {
    name = "disable-animation",
    match = { namespace = "hyprpicker|selection" },
    no_anim = true,
}

hl.layer_rule {
    name = "fade-animation",
    match = { namespace = "logout_dialog|qs_wallpaper" },
    animation = "fade"
}

hl.layer_rule {
    name = "slide-animation-bottom",
    match = { namespace = "qs_launcher" },
    animation = "slide bottom"

}

hl.layer_rule {
    name = "slide-animation-right",
    match = { namespace = "qs_notification_center" },
    animation = "slide right"
}
