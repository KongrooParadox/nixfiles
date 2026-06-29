{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        device = lib.mkDefault "/dev/vda";
      };
    };
  };

  fileSystems = {
    "/boot" = {
      label = "esp";
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/" = {
      label = "nixos";
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
