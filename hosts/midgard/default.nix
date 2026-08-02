{
  config,
  inputs,
  lib,
  ...
}:
let
  localModel = "gemma-4-E4B-it-qat-GGUF";
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
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

  kp = {
    arr = {
      dispatcharr.enable = true;
      enable = true;
      computeBasePath = "/mnt/compute";
      mediaBasePath = "/mnt/media";
      deluge.wireguardInterface = "wg-p2p-2";
    };
    home-manager.enable = true;
    immich = {
      enable = true;
      mediaPath = "/mnt/media/gallery";
    };
    impermanence.enable = true;
    llm = {
      enable = true;
      llamaCpp = {
        enable = true;
        alias = localModel;
        modelFile = "gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf";
        modelUrl = "https://huggingface.co/unsloth/gemma-4-E4B-it-qat-GGUF/resolve/main/gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf";
        contextSize = 24576;
      };
    };
    media-player.enable = true;
    networking.systemd = {
      enable = true;
      nicList = [
        {
          dhcp = "yes";
          name = "enp4s0";
          prefix = "10";
          requiredForOnline = "yes";
        }
      ];
    };
    podman.enable = true;
    samba.server.enable = true;
    tailscale.enable = false;
    zfs = {
      enable = true;
      encryptionKeys = [
        "root.key"
        "rust.key"
      ];
      extraPools = [ "rust" ];
      hostId = "c9e13eac";
    };
  };

  boot = {
    initrd.kernelModules = [
      "nvidia"
      "i915"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [ "nvidia-drm.fbdev=1" ];
  };

  networking = {
    useDHCP = false;
    networkmanager.enable = lib.mkForce false;
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
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      forceFullCompositionPipeline = true;
    };
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };
}
