{
  lib,
  ...
}:
{
  options.kp.impermanence = {
    enable = lib.mkEnableOption "impermanence for darwin";
  };
}
