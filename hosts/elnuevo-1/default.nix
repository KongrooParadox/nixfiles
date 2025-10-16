{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  kp = {
    home-assistant.enable = true;
    impermanence.enable = true;
    reverseProxy.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    tailscale = {
      advertisedRoutes = [ "192.168.2.0/24" ];
      exitNode = false;
      subnetRouter = true;
    };
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
    };
  };

  networking = {
    bridges = {
      "br0" = {
        interfaces = [ "eno1" ];
      };
    };
    hostId = "02ce4009";
    firewall = {
      allowedUDPPortRanges = [
        {
          from = 40000;
          to = 40010;
        }
      ];
      allowedTCPPortRanges = [
        {
          from = 40000;
          to = 40010;
        }
      ];
    };
    useDHCP = false;
    interfaces."br0".useDHCP = true;
  };

}
