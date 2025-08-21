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
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
    };
  };

  home-manager.users.fatiha.home.packages = [
    pkgs.zoom-us
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
    hostId = "050d02a0";
  };
}
