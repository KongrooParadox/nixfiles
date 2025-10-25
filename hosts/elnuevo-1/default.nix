{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  kp = {
    arr = {
      enable = true;
      mediaBasePath = "/mnt/share/media";
      computeBasePath = "/var/lib/compute";
    };
    impermanence.enable = true;
    media-player = {
      dataDir = "/var/lib/jellyfin";
      enable = true;
    };
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
    ups.enable = true;
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
