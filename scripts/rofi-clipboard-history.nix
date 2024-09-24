{ pkgs, ... }:

pkgs.writeShellScriptBin "rofi-clipboard-history" ''
  if pgrep -x "rofi" > /dev/null; then
    # Rofi is running, kill it
    pkill -x rofi
    exit 0
  fi
  cliphist list | rofi -dmenu | cliphist decode | wl-copy
''
