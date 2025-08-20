{
  host,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
    inputs.apple-silicon.nixosModules.default
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  virtualization.enable = true;

  kp.zfs.enable = true;

  networking = {
    hostId = "a3c9f91c";
    useDHCP = false;
    bridges = {
      "br0" = {
        interfaces = [ "end0" ];
      };
    };
    interfaces."br0".useDHCP = true;
  };

  impermanence.enable = true;
  samba.client = {
    enable = true;
    uid = "1001";
    gid = "990";
  };
  ups.enable = true;
  reverseProxy.enable = true;
  arr = {
    enable = true;
    mediaBasePath = "/mnt/share/media";
    computeBasePath = "/var/lib";
  };
  media-player.enable = true;
  tailscale.enable = false;
}
