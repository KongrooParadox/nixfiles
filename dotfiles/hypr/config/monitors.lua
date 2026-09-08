hl.monitor({
  mode     = "preferred",
  output   = "",
  scale    = "auto",
  position = "auto",
})
hl.monitor({
  mode     = "2560x1600@60.0",
  output   = "eDP-1",
  position = "1200x3187",
  scale    = "1.67",
  disabled = IsLidClosed(),
})
hl.monitor({
  mode      = "1920x1200@59.95",
  output    = "desc:Hewlett Packard HP E241i CN444907WG",
  position  = "0x1740",
  scale     = "1.0",
  transform = 1,
})
hl.monitor({
  mode     = "1920x1080@60.00",
  output   = "desc:Iiyama North America PLG2488H 0",
  position = "1200x2287",
  scale    = "1.2",
})

hl.workspace_rule({
  default = true,
  monitor = "desc:Iiyama North America PLG2488H 0",
  persistent = true,
  workspace = "1",
})
hl.workspace_rule({
  default = true,
  layout = "scrolling",
  monitor = "desc:Hewlett Packard HP E241i CN444907WG",
  persistent = true,
  workspace = "2",
})
hl.workspace_rule({
  monitor = "desc:Iiyama North America PLG2488H 0",
  persistent = true,
  workspace = "3",
})
hl.workspace_rule({
  default = true,
  monitor = "desc:Hewlett Packard HP E241i CN444907WG",
  workspace = "4",
})
hl.workspace_rule({
  monitor = "desc:Iiyama North America PLG2488H 0",
  workspace = "5",
})
hl.workspace_rule({
  monitor = "desc:Hewlett Packard HP E241i CN444907WG",
  workspace = "6",
})
hl.workspace_rule({
  monitor = "desc:Iiyama North America PLG2488H 0",
  workspace = "7",
})
hl.workspace_rule({
  monitor = "desc:Hewlett Packard HP E241i CN444907WG",
  workspace = "8",
})
hl.workspace_rule({
  monitor = "eDP-1",
  workspace = "9",
})
hl.workspace_rule({
  monitor = "eDP-1",
  workspace = "10",
})
