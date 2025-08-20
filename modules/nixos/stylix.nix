{
  config,
  lib,
  pkgs,
  ...
}:
let
  needsStylix =
    config.kp.desktop.environment == "hyprland" || config.kp.desktop.environment == "macos";
in
{
  config = lib.mkIf (config.kp.desktop.enable && needsStylix) {
    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
