{ config, pkgs, ... }:
let
  script =
    if config.kp.hyprland.bar == "noctalia" then
      ''
        COMMAND=$1
        SIGN=''${1/up/+}
        SIGN=''${SIGN/down/-}
        ${pkgs.noctalia}/bin/noctalia msg "brightness-''${COMMAND} 5%"
        ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 --device kbd_backlight set "5%''${SIGN}"
      ''
    else
      ''
        SIGN=''${1/up/+}
        SIGN=''${SIGN/down/-}
        ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set "5%''${SIGN}";
        ${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 --device kbd_backlight set "5%''${SIGN}"
      '';
in
pkgs.writeShellScriptBin "brightness-control" script
