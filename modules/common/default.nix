{
  config,
  lib,
  ...
}:
{
  imports = [
    ./fonts.nix
    ./home-manager.nix
    ./sops.nix
    ./stylix.nix
  ];

  # Heavy desktop apps, installed only on the hosts that ask for them
  options.kp.apps = {
    krita.enable = lib.mkEnableOption "Krita";
    prusa-slicer.enable = lib.mkEnableOption "PrusaSlicer";
    wine.enable = lib.mkEnableOption "Wine (64-bit with 32-bit support, Wayland)";
  };

  config = {
    kp.stylix.enable = true;

    sops.secrets."github/api-key" = { };

    nix = {
      extraOptions = ''
        !include ${config.sops.secrets."github/api-key".path}
      '';
      settings = {
        substituters = [
          "https://nix-community.cachix.org"
          "https://cache.saumon.network/proxmox-nixos"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
        ];
      };
    };
  };
}
