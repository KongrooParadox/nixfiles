{ lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

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
      efi.canTouchEfiVariables = true;
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

  networking = {
    hostId = "8bd9a73c";
    hostName = "yggdrasil";
    networkmanager.enable = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  time.timeZone = "Europe/Paris";

  security.sudo.wheelNeedsPassword = false;

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$y$j9T$hPF6s6mTZ/zrhpR53hLG/0$gYqOtNdDwJxrxn3uMEHULC3zwera8885UbzAnjymBQ3";
    openssh.authorizedKeys.keys = (import ../../modules/ssh.nix).keys;
  };

  # Impermanence state
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];

  services.openssh = {
    enable = true;
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

  nix = {
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1m";
    };
    settings = {
      trusted-users = [ "root" "ops" ];
      experimental-features = [
        "nix-command"
          "flakes"
      ];
      auto-optimise-store = true;
    };
  };

    environment = {
      systemPackages = with pkgs; [
        git
        # hddtemp # monitor hdd temp during burn in
        # ksh # required for burn in script bht
        # lsscsi # required for burn in script bht
        # lvm2 # required for burn in script bht
        # mailutils # required for burn in script bht
        # smartmontools # required for burn in script bht
        # sysstat # required for burn in script bht
        tmux
        tree
        vim
      ];
    };

  system.stateVersion = "24.05";
}
