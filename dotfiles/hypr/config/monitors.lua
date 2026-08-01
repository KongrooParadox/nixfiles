-- TODO : test with monitors
--
-- workspace = 1,monitor:DVI-I-2,default:true,persistent:true
-- workspace = 2,monitor:DVI-I-1,default:true,persistent:true
-- workspace = 3,monitor:DP-1,persistent:true
-- workspace = 4,monitor:eDP-1,default:true,persistent:true
-- workspace = 5,monitor:DVI-I-2,persistent:true
-- workspace = 6,monitor:DVI-I-1,persistent:true
-- workspace = 7,monitor:DP-1,persistent:true
-- workspace = 8,monitor:eDP-1,persistent:true
-- workspace = 9,monitor:DVI-I-2,persistent:true
-- workspace = 10,monitor:DVI-I-1,persistent:true
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = "auto",
})
hl.monitor({
  output   = "eDP-1",
  mode     = "2560x1600@60.0",
  position = "4290x1685",
  scale    = "1.67",
})
hl.monitor({
  output    = "DVI-I-1",
  mode      = "1920x1200@59.95",
  position  = "2410x105",
  scale     = "1.0",
  transform = 1,
})
hl.monitor({
  output   = "DVI-I-2",
  mode     = "2560x1440@59.95",
  position = "3610x245",
  scale    = "1.0",
})
hl.monitor({
  output   = "DP-1",
  mode     = "1920x1080@60.0",
  position = "6170x555",
  scale    = "1.0",
})
