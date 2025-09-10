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
        tasmota-tv      IN  A     10.10.111.14
        tasmota-nas     IN  A     10.10.111.27
        tasmota-desk    IN  A     10.10.111.28
        tasmota-window  IN  A     10.10.111.29
        elnuevo-2       IN  A     10.10.111.100
        elnuevo-1       IN  A     10.10.111.99
        home-assistant  IN  CNAME elnuevo-1
        yggdrasil       IN  A     10.10.111.101
        gallery         IN  CNAME yggdrasil
        smb             IN  CNAME yggdrasil
        njord           IN  A     10.10.111.26
                        IN  A     10.10.111.31
        baldur          IN  A     10.10.111.20
                        IN  A     10.10.111.21
        heimdall        IN  A     10.10.111.102
        deluge          IN  CNAME heimdall
        jellyfin        IN  CNAME heimdall
        lidarr          IN  CNAME heimdall
        nzbget          IN  CNAME heimdall
        prowlarr        IN  CNAME heimdall
        radarr          IN  CNAME heimdall
        readarr         IN  CNAME heimdall
        sonarr          IN  CNAME heimdall
        lordi           IN  A     10.10.111.18
        kronos          IN  A     10.10.111.103
        thor            IN  A     10.10.111.104
        pi401           IN  A     10.10.111.123
        livebox         IN  A     10.10.111.254
      '';
    };
    home-manager.enable = true;
    impermanence.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    tailscale = {
      advertisedRoutes = [ "10.10.111.0/24" ];
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
