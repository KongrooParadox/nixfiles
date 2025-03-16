{ lib, inputs, ... }:

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
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      "zfs-dataset/yggdrasil/root.key" = {};
      "zfs-dataset/yggdrasil/rust.key" = {};
    };
  };

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

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/acme"
      "/var/lib/nixos"
      "/var/lib/postgresql"
      "/var/lib/redis-immich/"
      "/var/lib/samba"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

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
