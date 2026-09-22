{
  config,
  pkgs,
}:
let
  script =
    if config.kp.hyprland.bar == "noctalia" then
      "${pkgs.noctalia}/bin/noctalia msg panel-open launcher"
    else
      ''
        if pgrep -x "rofi" > /dev/null; then
          # Rofi is running, kill it
          pkill -x rofi
          exit 0
        fi
        rofi -show drun
      '';
in
pkgs.writeShellScriptBin "launcher" script
