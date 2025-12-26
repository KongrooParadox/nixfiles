{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.kp.stylix.enable) {
    # stylix.targets.qt.enable = false;
    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };
}
