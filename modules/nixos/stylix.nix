{
  config,
  lib,
  pkgs,
  ...
}:
let
  needsStylix = config.desktop.environment == "hyprland" || config.desktop.environment == "macos";
in
{
  config = lib.mkIf (config.desktop.enable && needsStylix) {
    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
