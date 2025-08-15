{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware-configuration.nix
  ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
  };

  sops = {
    secrets = {
      "zfs-dataset/yggdrasil/root.key" = { };
      "zfs-dataset/yggdrasil/rust.key" = { };
    };
  };

  hm.enable = true;
  immich.enable = true;
  reverseProxy.enable = true;
  storage.enable = true;
  samba.server.enable = true;
  tailscale.enable = false;

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        mirroredBoots = [
          {
            devices = [ "/dev/disk/by-path/pci-0000:02:00.0-ata-4" ];
            path = "/boot";
          }
          {
            devices = [ "/dev/disk/by-path/pci-0000:02:00.0-ata-5" ];
            path = "/boot-fallback";
          }
        ];
      };
      systemd-boot.enable = lib.mkForce false;
    };

    initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r root/local/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-path";
    };
  };

  impermanence = {
    enable = true;
    extraDirectories = [
      "/var/lib/acme"
      "/var/lib/postgresql"
      "/var/lib/redis-immich/"
      "/var/lib/samba"
    ];
  };

}
