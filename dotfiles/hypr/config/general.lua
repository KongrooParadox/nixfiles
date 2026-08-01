hl.config({
  general = {
    gaps_in          = 0,
    gaps_out         = 0,
    border_size      = 0,
    col              = {
      active_border   = { colors = { "rgb(BF616A)", "rgb(88C0D0)" }, angle = 45 },
      inactive_border = "rgb(3B4252)",
    },
    resize_on_border = true,
    layout           = "dwindle",
  },

  decoration = {
    rounding       = 0,
    rounding_power = 1,

    blur           = {
      enabled           = true,
      size              = 5,
      passes            = 3,
      new_optimizations = true,
      ignore_opacity    = false,
      vibrancy          = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },
})
