{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  kp = {
    dns-server = {
      enable = true;
      localDomain = "skynet.local";
      zone = ''
        $ORIGIN skynet.local.
        $TTL 3600 ; default expiration time (in seconds) of all RRs without their own TTL value
        skynet.local.   IN  SOA   elnuevo-2.skynet.local. noreply.kongroo.anonaddy.com. ( 2020091025 7200 3600 1209600 3600 )
        skynet.local.   IN  NS    elnuevo-2
        skynet.local.   IN  NS    livebox
        tasmota-grill   IN  A     192.168.2.2
        tasmota-window  IN  A     192.168.2.3
        tasmota-desk    IN  A     192.168.2.4
        tasmota-laptop  IN  A     192.168.2.5
        elnuevo-2       IN  A     192.168.2.100
        home-assistant  IN  CNAME elnuevo-2
        elnuevo-1       IN  A     192.168.2.99
        yggdrasil       IN  A     192.168.2.101
        gallery         IN  CNAME yggdrasil
        smb             IN  CNAME yggdrasil
        njord           IN  A     192.168.2.25
        baldur          IN  A     192.168.2.20
        heimdall        IN  A     192.168.2.102
        deluge          IN  CNAME elnuevo-1
        jellyfin        IN  CNAME elnuevo-1
        lidarr          IN  CNAME elnuevo-1
        nzbget          IN  CNAME elnuevo-1
        prowlarr        IN  CNAME elnuevo-1
        radarr          IN  CNAME elnuevo-1
        readarr         IN  CNAME elnuevo-1
        sonarr          IN  CNAME elnuevo-1
        livebox         IN  A     192.168.2.254
      '';
    };
    home-assistant.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
    reverseProxy.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    tailscale = {
      advertisedRoutes = [ "192.168.2.0/24" ];
      autoconnect = true;
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
    hostId = "db46c034";
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
