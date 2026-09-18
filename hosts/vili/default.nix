{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    loader = {
      grub = {
        enable = false;
        device = lib.mkDefault "/dev/vda";
      };
      systemd-boot.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = true;
    };
  };

  kp = {
    dns-server.enable = true;
    home-assistant.enable = true;
    tailscale = {
      autoconnect = true;
      exitNode = false;
      subnetRouter = true;
    };
  };
}
