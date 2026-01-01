{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-inspiron-7405
    ./hardware-configuration.nix
  ];

  services.xserver.xkb.layout = lib.mkForce "fr,ara,us";

  kp = {
    desktop = {
      enable = true;
      environment = "gnome";
    };
    home-manager.enable = true;
    impermanence.enable = true;
    kids.enable = true;
    system.language = "fr_FR";
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "050d02a0";
    };
  };

  home-manager.users.fatiha.home.packages = [
    pkgs.zoom-us
  ];
}
