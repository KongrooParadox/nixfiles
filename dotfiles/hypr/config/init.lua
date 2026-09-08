function IsLidClosed()
  -- We check the kernel logs for the latest state of the lid switch
  local cmd = [[
    sleep 1 && timeout 2s journalctl -b |
    grep -Po 'macsmc.*SMC HID Event: \K.*' |
    tail -n1
  ]]
  local state = io.popen(cmd):read("*a"):gsub("^%s*(.-)%s*$", "%1")
  -- local lidOpened = "03 00 01"
  local lidClosed = "03 01 00"
  -- hl.notification.create({ text = string.format("isLidClosed : %s", state == lidClosed), timeout = 15000, icon = "info", font_size = 20 })
  return state == lidClosed
end

require("config/animations")
require("config/bindings")
require("config/env")
require("config/general")
require("config/misc")
require("config/monitors")
require("config/window-rules")

-- TODO
-- plugin {
--   hyprtrails {
--   }
-- }
