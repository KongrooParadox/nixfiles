{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    inputs.nixos-hardware.nixosModules.dell-inspiron-7405
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r zroot/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-path";
    };
  };

  services.xserver.xkb.layout = lib.mkForce "fr,ara,us";

  hm.enable = true;
  home-manager.users.fatiha.home.packages = [
    pkgs.zoom-us
  ];

  # Because zfs tries to load encryption keys before sops secret is available
  systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

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

  sops = {
    secrets = {
      "zfs-dataset/baldur/encrypted.key" = { };
    };
  };

  impermanence.enable = true;

  system.language = "fr_FR";
  virtualization.enable = true;
}
