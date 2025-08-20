{
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
  };

  kp.zfs = {
    enable = true;
    encryptionKeys = [
      "root.key"
      "rust.key"
    ];
  };

  binary-cache.enable = true;
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
