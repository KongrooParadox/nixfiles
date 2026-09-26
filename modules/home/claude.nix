{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kp.claude = {
    enable = lib.mkEnableOption "Claude Code AI coding agent";
  };

  config = lib.mkIf config.kp.claude.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
