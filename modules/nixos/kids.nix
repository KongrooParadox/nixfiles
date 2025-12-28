{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.kids;
in
{
  options.kp.kids = {
    enable = lib.mkEnableOption "educational games for the kids";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gcompris
    ];
  };
}
