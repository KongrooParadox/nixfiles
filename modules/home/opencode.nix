{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kp.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
  };

  config = lib.mkIf config.kp.opencode.enable {
    home.packages = [ pkgs.opencode ];
  };
}
