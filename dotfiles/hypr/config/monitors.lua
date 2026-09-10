local portraitMonitor = "desc:Hewlett Packard HP E241i CN444907WG"
local mainMonitor = "desc:iiyama Corporation PLG2488H 0"
local laptopMonitor = "eDP-1"

hl.monitor({
  mode     = "preferred",
  output   = "",
  scale    = "auto",
  position = "auto",
})
hl.monitor({
  output   = "DP-1",
  mode     = "1280x1024@60.00",
  position = "4200x4287",
  scale    = "1.0",
})
hl.monitor({
  mode     = "2560x1600@60.0",
  output   = laptopMonitor,
  position = "1200x3187",
  scale    = 1.67,
  disabled = IsLidClosed(),
  vrr      = 0,
})
hl.monitor({
  mode      = "1920x1200@59.95",
  output    = portraitMonitor,
  position  = "0x1740",
  scale     = 1.0,
  transform = 1,
  vrr       = 0,
})
hl.monitor({
  mode     = "1920x1080@60.00",
  output   = mainMonitor,
  position = "1200x2107",
  scale    = 1.2,
  vrr      = 0,
})

hl.workspace_rule({
  default = true,
  monitor = mainMonitor,
  persistent = true,
  workspace = "1",
})
hl.workspace_rule({
  default = true,
  layout = "scrolling",
  monitor = portraitMonitor,
  persistent = true,
  workspace = "2",
})
hl.workspace_rule({
  monitor = mainMonitor,
  persistent = true,
  workspace = "3",
})
hl.workspace_rule({
  default = true,
  monitor = portraitMonitor,
  workspace = "4",
})
hl.workspace_rule({
  monitor = mainMonitor,
  workspace = "5",
})
hl.workspace_rule({
  monitor = portraitMonitor,
  workspace = "6",
})
hl.workspace_rule({
  monitor = mainMonitor,
  workspace = "7",
})
hl.workspace_rule({
  monitor = portraitMonitor,
  workspace = "8",
})
hl.workspace_rule({
  monitor = laptopMonitor,
  workspace = "9",
})
hl.workspace_rule({
  monitor = laptopMonitor,
  workspace = "10",
})
