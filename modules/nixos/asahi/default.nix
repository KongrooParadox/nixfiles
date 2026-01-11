{
  config,
  lib,
  inputs,
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
    environment = {
      sessionVariables.AQ_DRM_DEVICES = lib.mkForce "/dev/dri/card2";
      systemPackages = with inputs.nixos-muvm-steam.packages.aarch64-linux; [
        muvm
        muvm-steam
      ];
    };

    hardware.asahi = {
      peripheralFirmwareDirectory = ./firmware;
      setupAsahiSound = true;
    };
    powerManagement = {
      powertop.enable = lib.mkForce false;
    };

    nix.settings = {
      extra-substituters = [
        "https://nixos-apple-silicon.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };
  };
}
