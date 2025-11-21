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

  kp = {
    binary-cache.enable = true;
    home-manager.enable = true;
    immich.enable = true;
    impermanence.enable = true;
    samba.server.enable = true;
    storage.enable = true;
    tailscale.enable = false;
    zfs = {
      enable = true;
      encryptionKeys = [
        "root.key"
        "rust.key"
      ];
    };
  };

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
}
