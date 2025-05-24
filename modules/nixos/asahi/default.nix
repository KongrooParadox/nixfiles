{
  config,
  lib,
  ...
}:
let
  cfg = config.asahi;
in
{
  options.asahi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable Asahi Apple Silicon drivers.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.asahi = {
      experimentalGPUInstallMode = "replace";
      peripheralFirmwareDirectory = ./firmware;
      useExperimentalGPUDriver = true;
      withRust = true;
      setupAsahiSound = true;
    };
  };
}
