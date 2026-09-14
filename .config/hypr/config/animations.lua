-- see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

hl.curve("quick_overshoot", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.curve("ease_in_out", { type = "bezier", points = { { 0.37, 0 }, { 0.63, 1 } } })
hl.curve("ease_in_cubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })
hl.curve("ease_out_cubic", { type = "bezier", points = { { 0.33, 1 }, { 0.68, 1 } } })

hl.animation { leaf = "windows", enabled = true, speed = 6, bezier = "quick_overshoot", style = "slide" }
hl.animation { leaf = "workspaces", enabled = true, speed = 5, bezier = "overshoot", style = "slide" }
hl.animation { leaf = "layers", enabled = true, speed = 3, bezier = "ease_in_out", style = "slide" }
