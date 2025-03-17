{ inputs, ... }:
{
  imports = [
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  virtualization.enable = true;

  networking = {
    useDHCP = false;
    bridges = {
      "br0" = {
        interfaces = [ "end0" ];
      };
    };
    interfaces."br0".useDHCP = true;
  };

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

}
