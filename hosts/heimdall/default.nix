{
  host,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos/asahi
    ./disks.nix
    ./hardware-configuration.nix
    inputs.apple-silicon.nixosModules.default
    inputs.disko.nixosModules.disko
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  virtualization.enable = true;

  boot = {
    initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r zroot/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-path";
    };
  };

  sops = {
    secrets = {
      "zfs-dataset/${host}/encrypted.key" = { };
    };
  };

  # Because zfs tries to load encryption keys before sops secret is available
  systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

  networking = {
    hostId = "a3c9f91c";
    useDHCP = false;
    bridges = {
      "br0" = {
        interfaces = [ "end0" ];
      };
    };
    interfaces."br0".useDHCP = true;
  };
  impermanence.enable = true;
  samba.client = {
    enable = true;
    uid = "1001";
    gid = "990";
  };
  ups.enable = true;
  reverseProxy.enable = true;
  arr = {
    enable = true;
    mediaBasePath = "/mnt/share/media";
    computeBasePath = "/var/lib";
  };
  media-player.enable = true;
  tailscale.enable = false;
}
