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

  kp = {
    arr = {
      enable = true;
      mediaBasePath = "/mnt/share/media";
      computeBasePath = "/var/lib";
    };
    impermanence.enable = true;
    media-player.enable = true;
    reverseProxy.enable = true;
    samba.client = {
      enable = true;
      uid = "1001";
      gid = "990";
    };
    tailscale.enable = false;
    ups.enable = true;
    virtualization.enable = true;
    zfs.enable = true;
  };

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

}
