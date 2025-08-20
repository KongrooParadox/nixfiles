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

  hm.enable = true;
  home-manager.users.fatiha.home.packages = [
    pkgs.zoom-us
  ];

  kp = {
    zfs.enable = true;
  };

  desktop = {
    enable = true;
    environment = "gnome";
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
    hostId = "050d02a0";
  };

  impermanence.enable = true;

  system.language = "fr_FR";
  virtualization.enable = true;
}
