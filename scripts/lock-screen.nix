{
  config,
  pkgs,
}:
let
  script =
    if config.kp.hyprland.bar == "noctalia" then
      ''
        ${pkgs.noctalia}/bin/noctalia msg session lock
      ''
    else
      ''
        ${pkgs.hyprlock}/bin/hyprlock
      '';
in
pkgs.writeShellScriptBin "lock-screen" script
