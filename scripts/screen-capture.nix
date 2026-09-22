{
  config,
  pkgs,
}:
let
  command =
    if config.kp.hyprland.bar == "noctalia" then
      ''
        ${pkgs.noctalia}/bin/noctalia msg screenshot-region
      ''
    else
      ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
      '';
in
pkgs.writeShellScriptBin "screen-capture" command
