#! /bin/bash
# Setup xsetwacom script for Intuos 3 9x12
# License: CC-0/Public-Domain license
# author: deevad

if [[ $# -eq 1 ]]; then
    monitor="$1"
else
    monitor="DVI-I-2-2"
fi
# Tablet definition
tabletstylus="GAOMON Gaomon Tablet_M10KPRO stylus"
tabletpad="GAOMON Gaomon Tablet_M10KPRO Pad pad"
touchpad="GAOMON Gaomon Tablet_MK10PRO Touch Strip pad" #unsupported
dialpad="GAOMON Gaomon Tablet Dial pad" #unsupported
# Display all available option:
#xsetwacom get "$tabletstylus" all
#xsetwacom get "$tabletpad" all
#xsetwacom get "$touchpad" all
#xsetwacom get "$dialpad" all

# Reset
xsetwacom --set "$tabletstylus" ResetArea

# Map surface of the tablet to a monitor (in case of multiple)
# Note: get the name of the monitor with xrandr
xsetwacom --set "$tabletstylus" MapToOutput "$monitor"

# Auto proportional Mapping:
# xsetwacom get "$tabletstylus" Area
# default: 0 0 50800 31750
# Enter under the resolution of your monitor:
# xrandr | grep DVI-I-1-1 | awk '{ print $(NF-11) }'
screenX=$(xrandr | grep $monitor | awk '{ print $(NF-11) }' | cut -d '+' -f1 | cut -d 'x' -f1)
screenY=$(xrandr | grep $monitor | awk '{ print $(NF-11) }' | cut -d '+' -f1 | cut -d 'x' -f2)
echo -e "Monitor : $monitor \nResolution: ${screenX}x${screenY}"
Xtabletmaxarea=50800
Ytabletmaxarea=31750
areaY=$(( $screenY * $Xtabletmaxarea / $screenX ))
xsetwacom --set "$tabletstylus" Area 0 0 "$Xtabletmaxarea" "$areaY"

# Stylus button:
xsetwacom --set "$tabletstylus" Button 1 1 # default, to click and draw
xsetwacom --set "$tabletstylus" Button 2 "key Control_L" # Ctrl = color picker
xsetwacom --set "$tabletstylus" Button 3 3 # default (Right click)

# Tweaks
# Pressure curve:
xsetwacom --set "$tabletstylus" PressureCurve 0 0 100 100
# Softer
#xsetwacom --set "$tabletstylus" PressureCurve 0 10 40 85
# Configuration data trimming and suppression
# The event of this device are good; if you have CPU better to not filter
# them at operating system level to not loose any sensitivity.
# Minimal trimming is also good.
xsetwacom --set "$tabletstylus" Suppress 0 # data pt.s filtered, default is 2, 0-100
xsetwacom --set "$tabletstylus" RawSample 1 # data pt.s trimmed, default is 4, 1-20

# For left-handed mode (rotation):
#xsetwacom --set "$tabletstylus" Rotate half

# Buttons
# Note: touchpad around 10 button is not supported
#     +-----+
#     |  1  |
#     +-----+
#     |  2  |
#     +-----+
#     |  3  |
#     +-----+
#     |  8  |
#     +-----+
#     |  9  |
#     +-----+
# +---+-----+---+
# |             |
# |   +-----+   |
# |   | 10  |   |
# |   |     |   |
# |   +-----+   |
# |             |
# +---+-----+---+
#     +-----+
#     | 11  |
#     +-----+
#     | 12  |
#     +-----+
#     | 13  |
#     +-----+
#     | 14  |
#     +-----+
#     | 15  |
#     +-----+
xsetwacom --set "$tabletpad" Button 1 "key Control_L" # Ctrl = color picker
xsetwacom --set "$tabletpad" Button 2 "key KP_Divide" # / = Switch to previous used brush preset
xsetwacom --set "$tabletpad" Button 3 "key Shift_L" # Shift = Resize brush
xsetwacom --set "$tabletpad" Button 8 "key v" # v = line
xsetwacom --set "$tabletpad" Button 9 "key m" # m = mirror

xsetwacom --set "$tabletpad" Button 10 "key e" # e = eraser

xsetwacom --set "$tabletpad" Button 11 "key r" # r = pick layer
xsetwacom --set "$tabletpad" Button 12 "key l" # l = select lighter color
xsetwacom --set "$tabletpad" Button 13 "key k" # k = select darker color
xsetwacom --set "$tabletpad" Button 14 "key o" # o = more opacity
xsetwacom --set "$tabletpad" Button 15 "key i" # i = less opacity
