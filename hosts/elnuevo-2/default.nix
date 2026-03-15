{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        9191
      ];
      allowedUDPPorts = [ 9191 ];
    };
  };
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
        jellyfin        IN  CNAME elnuevo-2
        elnuevo-1       IN  A     192.168.2.99
        proxmox         IN  CNAME elnuevo-1
        yggdrasil       IN  A     192.168.2.101
        gallery         IN  CNAME yggdrasil
        smb             IN  CNAME yggdrasil
        njord           IN  A     192.168.2.25
        baldur          IN  A     192.168.2.20
        heimdall        IN  A     192.168.2.102
        bazarr          IN  CNAME heimdall
        deluge          IN  CNAME heimdall
        lidarr          IN  CNAME heimdall
        nzbget          IN  CNAME heimdall
        prowlarr        IN  CNAME heimdall
        radarr          IN  CNAME heimdall
        readarr         IN  CNAME heimdall
        sonarr          IN  CNAME heimdall
        livebox         IN  A     192.168.2.254
      '';
    };
    home-assistant.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
    media-player = {
      dataDir = "/var/lib/jellyfin";
      enable = true;
    };
    networking.systemd = {
      enable = true;
      nicList = [
        {
          dhcp = "yes";
          name = "eno1";
          prefix = "10";
          requiredForOnline = "yes";
        }
      ];
    };
    podman.enable = true;
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
      hostId = "db46c034";
    };
  };
}
