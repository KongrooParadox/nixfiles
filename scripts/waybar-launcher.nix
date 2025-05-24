{ pkgs }:
pkgs.writeShellScriptBin "waybar-launcher" ''
  if pgrep "waybar-wrapped" > /dev/null; then
    # Waybar is running, kill it
    pkill waybar-wrapped
  fi
  sleep 0.2
  waybar
''
