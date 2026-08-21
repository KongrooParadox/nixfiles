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

  home-manager.users.ops.kp = {
    irc.enable = true;
  };

  kp = {
    arr = {
      bazarr.enable = false;
      deluge.enable = false;
      dispatcharr.enable = true;
      enable = true;
      lidarr.enable = false;
      nzbget.enable = false;
      prowlarr.enable = false;
      radarr.enable = false;
      sonarr.enable = false;
    };
    binary-cache.enable = true;
    home-manager.enable = true;
    immich.enable = true;
    impermanence.enable = true;
    networking.systemd = {
      enable = true;
      nicList = [
        {
          dhcp = "yes";
          name = "enp7s0";
          prefix = "10";
          requiredForOnline = "yes";
        }
      ];
    };

    samba.server.enable = true;
    storage.enable = true;
    tailscale.enable = false;
    zfs = {
      enable = true;
      encryptionKeys = [
        "root.key"
        "rust.key"
      ];
      extraPools = [ "rust" ];
      hostId = "8bd9a73c";
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
