{ inputs, lib, pkgs, ... }:

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
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "zfs-dataset/midgard/root.key" = {};
      "zfs-dataset/midgard/rust.key" = {};
    };
  };

  reverseProxy.enable = true;
  arr = {
    enable = true;
    deluge.wireguardInterface = "wg-p2p-2";
  };
  media-player.enable = true;
  tailscale.enable = false;
  immich = {
    enable = true;
    mediaPath = "/mnt/media/gallery";
  };

  boot = {
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r root/local/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportAll = true;
      forceImportRoot = true;
      devNodes = "/dev/disk/by-path";
    };
  };


  networking = {
    hostId = "c9e13eac";
    useDHCP = false;
    networkmanager.enable = lib.mkForce false;
  };

  systemd.network = {
    enable = true;
    networks."40-enp4s0" = {
      matchConfig.Name = "enp4s0";
      networkConfig.DHCP = "yes";
      linkConfig.RequiredForOnline = "yes";
    };
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
