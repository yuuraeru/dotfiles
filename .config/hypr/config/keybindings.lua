---------------------
---- KEYBINDINGS ----
---------------------

-- see https://wiki.hypr.land/Configuring/Basics/Binds/

local utils = require("utils")

-- Programs
local terminal = "kitty"
local file_manager = "nemo"
local browser = "librewolf"
local launcher = "qs ipc call launcher toggle"
local clipboard = "qs ipc call clipboard toggle"
local emoji = "qs ipc call emoji toggle"
local notification_center = "qs ipc call notification toggle"
local color_picker = "hyprpicker -an"
local grimblast = "~/.local/bin/grimblast -nf"
local wallpaper_manager = "qs ipc call wallpapermanager toggle"

local screenshot_template = "~/Pictures/Screenshots/Screenshot_$(date +%Y%m%d_%H%M%S).png"

local bind = hl.bind
local exec = hl.dsp.exec_cmd

bind("SUPER + SPACE", exec(launcher), { desc = "Open app launcher" })
bind("SUPER + T", exec(terminal))
bind("SUPER + B", exec(browser))
bind("SUPER + E", exec(file_manager))
bind("SUPER + V", exec(clipboard))
bind("SUPER + PERIOD", exec(emoji))
bind("SUPER + SHIFT + N", exec(notification_center))
bind("SUPER + SHIFT + C", exec(color_picker))
bind("SUPER + SHIFT + W", exec(wallpaper_manager))

bind("F11", hl.dsp.window.fullscreen())
bind("SUPER + F11", hl.dsp.window.fullscreen { mode = "maximized" })
bind("SUPER + W", hl.dsp.window.close())
bind("SUPER + C", hl.dsp.window.center())
bind("Pause", exec("wl-freeze -a"))
bind("SUPER + Pause", hl.dsp.window.kill())

bind("SUPER + F", hl.dsp.window.float { action = "toggle" })
bind("SUPER + P", hl.dsp.window.pseudo())
bind("SUPER + S", hl.dsp.layout("togglesplit"))

bind("Print", exec(grimblast .. " copy area"))
bind("SUPER + Print", exec(grimblast .. " copysave area " .. screenshot_template))
bind("CTRL + F12", exec(grimblast .. " copy output"))
bind("SUPER + F12", exec(grimblast .. " copysave output " .. screenshot_template))

bind("CTRL + ALT + DELETE", exec("pkill wlogout || wlogout"))
bind("SUPER + SHIFT + DELETE", hl.dsp.exit())
bind("SUPER + SHIFT + R", exec("hyprctl reload"))

bind("SUPER + Z", exec("pamixer --default-source -t"))
bind("SUPER + Tab", utils.toggle_layout)

local directions = {
    { "left",  "H", -10, 0 },
    { "right", "L", 10,  0 },
    { "up",    "K", 0,   -10 },
    { "down",  "J", 0,   10 },
}

for _, pair in ipairs(directions) do
    local direction = pair[1]
    local key = pair[2]
    local x = pair[3]
    local y = pair[4]

    local focus = hl.dsp.focus { direction = direction }
    local move = hl.dsp.window.move { direction = direction }
    local resize = hl.dsp.window.resize { x = x, y = y, relative = true }

    bind("SUPER + " .. direction, focus)
    bind("SUPER + " .. key, focus)

    bind("SUPER + SHIFT + " .. direction, move)
    bind("SUPER + SHIFT + " .. key, move)

    bind("SUPER + ALT + " .. direction, resize, { repeating = true })
    bind("SUPER + ALT + " .. key, resize, { repeating = true })
end

for i = 1, 10 do
    local key = i % 10
    bind("SUPER + " .. key, hl.dsp.focus { workspace = i })
    bind("SUPER + SHIFT + " .. key, hl.dsp.window.move { workspace = i })
end

bind("SUPER + SHIFT + ALT + left", hl.dsp.workspace.move { monitor = "-1" })
bind("SUPER + SHIFT + ALT + H", hl.dsp.workspace.move { monitor = "-1" })
bind("SUPER + SHIFT + ALT + right", hl.dsp.workspace.move { monitor = "+1" })
bind("SUPER + SHIFT + ALT + L", hl.dsp.workspace.move { monitor = "+1" })

bind("SUPER + mouse_down", hl.dsp.focus { workspace = "e+1" })
bind("SUPER + mouse_up", hl.dsp.focus { workspace = "e-1" })

bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })

bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
bind("SHIFT + XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+"),
    { locked = true, repeating = true })
bind("SHIFT + XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-"),
    { locked = true, repeating = true })

bind("XF86Sleep", exec("pkill wlogout || wlogout"), { locked = true })
bind("XF86MonBrightnessUp", exec("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", exec("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

bind("XF86AudioNext", exec("playerctl next"), { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })
