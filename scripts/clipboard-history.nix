{ config, pkgs, ... }:
let
  script =
    if config.kp.hyprland.bar == "noctalia" then
      "${pkgs.noctalia}/bin/noctalia msg panel-open clipboard"
    else
      ''
        if pgrep -x "rofi" > /dev/null; then
          # Rofi is running, kill it
          pkill -x rofi
          exit 0
        fi
        cliphist list | rofi -dmenu | cliphist decode | wl-copy
      '';
in
pkgs.writeShellScriptBin "clipboard-history" script
