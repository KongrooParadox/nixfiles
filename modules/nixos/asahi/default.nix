{
  config,
  lib,
  ...
}:
let
  cfg = config.kp.asahi;
in
{
  options.kp.asahi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable Asahi Apple Silicon drivers.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.asahi = {
      peripheralFirmwareDirectory = ./firmware;
      setupAsahiSound = true;
    };
    powerManagement = {
      powertop.enable = lib.mkForce false;
    };
  };
}
