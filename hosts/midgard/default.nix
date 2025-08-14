{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    ./disks.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      btop = super.btop.override { cudaSupport = true; };
    })
  ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
  };

  sops = {
    secrets = {
      "zfs-dataset/midgard/root.key" = { };
      "zfs-dataset/midgard/rust.key" = { };
    };
  };

  reverseProxy.enable = true;
  arr = {
    enable = true;
    computeBasePath = "/mnt/compute";
    mediaBasePath = "/mnt/media";
    deluge.wireguardInterface = "wg-p2p-2";
  };
  hm.enable = true;
  media-player.enable = true;
  tailscale.enable = false;
  immich = {
    enable = true;
    mediaPath = "/mnt/media/gallery";
  };
  impermanence.enable = true;
  samba.server.enable = true;

  boot = {
    initrd = {
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r root/local/root@blank
      '';
      kernelModules = [
        "nvidia"
        "i915"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
    };
    kernelParams = [ "nvidia-drm.fbdev=1" ];
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

  hardware = {
    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      prime = {
        nvidiaBusId = "PCI:1:0:0";
        offload = {
          enable = false;
          enableOffloadCmd = false;
        };
      };
      package = config.boot.kernelPackages.nvidiaPackages.production;
      forceFullCompositionPipeline = true;
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
