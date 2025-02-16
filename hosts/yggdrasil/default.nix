{ host, lib, inputs, ... }:

let
  fqdnHostname = "${host}.tavel.kongroo.ovh";
in
{
  imports =
    [
      inputs.disko.nixosModules.disko
      ./disks.nix
      ./hardware-configuration.nix
    ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
  };

  sops = {
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "zfs-dataset/yggdrasil/root.key" = {};
      "zfs-dataset/yggdrasil/fast.key" = {};
      "zfs-dataset/yggdrasil/rust.key" = {};
    };
  };

  immich = {
    enable = true;
    hostname = fqdnHostname;
  };
  arr = {
    enable = true;
    hostname = fqdnHostname;
  };
  media = {
    enable = true;
    hostname = fqdnHostname;
  };
  reverseProxy.enable = true;
  storage.enable = true;

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        mirroredBoots = [
          {
            devices = [ "/dev/disk/by-path/pci-0000:00:14.0-usb-0:2:1.0-scsi-0:0:0:0-part1" ];
            path = "/boot";
          }
          {
            devices = [ "/dev/disk/by-path/pci-0000:00:14.0-usb-0:3:1.0-scsi-0:0:0:0-part1" ];
            path = "/boot-fallback";
          }
        ];
      };
      systemd-boot.enable = lib.mkForce false;
    };

    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r root/local/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      # forceImportAll = true;
      # forceImportRoot = true;
      devNodes = "/dev/disk/by-path";
    };
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
