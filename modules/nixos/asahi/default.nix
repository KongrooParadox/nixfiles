{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.asahi;
in
{
  options.kp.asahi = {
    enable = lib.mkEnableOption "asahi drivers.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      let
        pkgsFex = pkgs.extend inputs.nixos-muvm-fex.overlays.default;
      in
      [ pkgsFex.muvm ];

    hardware.asahi = {
      peripheralFirmwareDirectory = ./firmware;
      setupAsahiSound = true;
    };
    powerManagement = {
      powertop.enable = lib.mkForce false;
    };
  };
}
