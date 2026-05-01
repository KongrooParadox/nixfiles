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
    dns-server = {
      enable = true;
      localDomain = "skynet.local";
      zone = ''
        $ORIGIN skynet.local.
        $TTL 3600 ; default expiration time (in seconds) of all RRs without their own TTL value
        skynet.local.   IN  SOA   vili.skynet.local. noreply.kongroo.anonaddy.com. ( 2020091025 7200 3600 1209600 3600 )
        skynet.local.   IN  NS    vili
        skynet.local.   IN  NS    livebox
        tasmota-grill   IN  A     192.168.2.2
        tasmota-window  IN  A     192.168.2.3
        tasmota-desk    IN  A     192.168.2.4
        tasmota-laptop  IN  A     192.168.2.5
        baldur          IN  A     192.168.2.20
        njord           IN  A     192.168.2.25
        elnuevo-1       IN  A     192.168.2.99
        proxmox         IN  CNAME elnuevo-1
        elnuevo-2       IN  A     192.168.2.100
        jellyfin        IN  CNAME elnuevo-2
        yggdrasil       IN  A     192.168.2.101
        gallery         IN  CNAME yggdrasil
        smb             IN  CNAME yggdrasil
        heimdall        IN  A     192.168.2.102
        bazarr          IN  CNAME heimdall
        deluge          IN  CNAME heimdall
        lidarr          IN  CNAME heimdall
        nzbget          IN  CNAME heimdall
        prowlarr        IN  CNAME heimdall
        radarr          IN  CNAME heimdall
        readarr         IN  CNAME heimdall
        sonarr          IN  CNAME heimdall
        vili            IN  A     192.168.2.103
        home-assistant  IN  CNAME vili
        livebox         IN  A     192.168.2.254
      '';
    };
    home-assistant.enable = true;
    tailscale = {
      advertisedRoutes = [ "192.168.2.0/24" ];
      autoconnect = true;
      exitNode = false;
      subnetRouter = true;
    };
  };
}
