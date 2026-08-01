hl.config({
  input = {
    accel_profile = "flat",
    kb_layout     = "us",
    kb_variant    = "alt-intl",
    kb_options    = "caps:escape",
    follow_mouse  = 1,
    repeat_rate   = 35,
    repeat_delay  = 200,
    sensitivity   = 0, -- -1.0 - 1.0, 0 means no modification.
    touchpad      = {
      natural_scroll = true,
      disable_while_typing = true,
      scroll_factor = 0.8,
    },
  },
})

hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

hl.config({
  master = {
    new_status = "master",
  },
})

hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
  },
})

hl.config({
  misc = {
    disable_hyprland_logo      = true, -- If true disables the random hyprland logo / anime girl background. :(
    force_default_wallpaper    = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
    initial_workspace_tracking = 0,
    key_press_enables_dpms     = false,
    mouse_move_enables_dpms    = true,
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})
