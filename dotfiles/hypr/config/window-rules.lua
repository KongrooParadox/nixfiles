--
-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.window_rule({
  name        = "rofi-no-borders",
  match       = { class = "^(rofi)$" },
  border_size = 0,
})
hl.window_rule({
  name         = "steam",
  match        = { class = "^(steam)$" },
  border_size  = 0,
  stay_focused = true,
})
hl.window_rule({
  name  = "float-apps",
  match = { class = "^(nm-connection-editor|nwg-look|qt5ct|mpv)$" },
  float = true,
})
hl.window_rule({
  name  = "float-resized-apps",
  match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager)$" },
  float = true,
  size  = { "monitor_w * 0.5", "monitor_h * 0.7" },
})
hl.window_rule({
  name      = "terminal",
  match     = { class = "^(Alacritty|kitty)$" },
  workspace = "1",
})
hl.window_rule({
  name      = "firefox",
  match     = { class = "^(firefox)$" },
  opacity   = "1.0 0.9",
  workspace = "2",
})
hl.window_rule({
  name      = "brave",
  match     = { class = "^(brave-browser)$" },
  opacity   = "1.0 0.9",
  workspace = "3",
})
hl.window_rule({
  name      = "thunar",
  match     = { class = "^(Thunar)$" },
  opacity   = "0.9 0.7",
  workspace = "4",
})


local suppressMaximizeRule = hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move  = "20 monitor_h-120",
  float = true,
})
