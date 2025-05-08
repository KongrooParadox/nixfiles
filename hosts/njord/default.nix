{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
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

  # Because zfs tries to load encryption keys before sops secret is available
  systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

  nixpkgs.overlays = [
    (final: prev: {
      linuxPackages_latest = prev.linuxPackages_latest // {
        zfs = prev.linuxPackages_latest.zfs.overrideAttrs (oldAttrs: rec {
          meta.broken = false;
          version = "2.3.2";
          src = prev.fetchurl {
            url = "https://github.com/openzfs/zfs/releases/download/zfs-${version}/zfs-${version}.tar.gz";
            hash = "sha256-lnjRCfHbpmINgo7QK02vaZ81+0mQC9QrpuK3Zv59MZA=";
          };
        });
      };
    })
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  desktop.enable = true;
  podman.enable = true;
  virtualization.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking = {
    hostId = "720320e5";
  };

  sops = {
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      "zfs-dataset/njord/encrypted.key" = {};
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  services = {
    openssh = {
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
  };

  samba.client.enable = true;
}
