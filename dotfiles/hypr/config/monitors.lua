local portraitMonitor = "desc:Hewlett Packard HP E241i CN444907WG"
local mainMonitor = "desc:iiyama Corporation PLG2488H 0"
local laptopMonitor = "eDP-1"

function notOnlyMonitor(laptopMonitor)
  monitors = hl.get_monitors()
  otherMonitors = 0
  for key, val in ipairs(monitors) do
    if val.name ~= laptopMonitor then
      otherMonitors = otherMonitors + 1
    end
  end
  return otherMonitors > 0
end

local function toggleInternalMonitor(monitor)
  local lidIsClosed = IsLidClosed()
  if lidIsClosed then
    hl.monitor({ output = monitor, disabled = true })
  else
    hl.monitor({ output = monitor, disabled = false })
  end
end

hl.bind("switch:Apple SMC power/lid events", function()
  toggleInternalMonitor(laptopMonitor)
end, { locked = true })

hl.monitor({
  mode = "preferred",
  output = "",
  scale = "auto",
  position = "auto",
})
hl.monitor({
  output = "DP-1",
  mode = "1280x1024@60.00",
  position = "4200x4287",
  scale = "1.0",
})
hl.monitor({
  mode = "2560x1600@60.0",
  output = laptopMonitor,
  position = "1200x3187",
  scale = 1.67,
  disabled = notOnlyMonitor(laptopMonitor) and IsLidClosed(),
  vrr = 0,
})
hl.monitor({
  mode = "1920x1200@59.95",
  output = portraitMonitor,
  position = "0x1740",
  scale = 1.0,
  transform = 1,
  vrr = 0,
})
hl.monitor({
  mode = "1920x1080@60.00",
  output = mainMonitor,
  position = "1200x2107",
  scale = 1.2,
  vrr = 0,
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
