{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

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

  reverseProxy.enable = true;
  home-assistant.enable = true;

  dns-server = {
    enable = true;
    localDomain = "skynet.local";
    zone = ''
      $ORIGIN skynet.local.
      $TTL 3600 ; default expiration time (in seconds) of all RRs without their own TTL value
      skynet.local.   IN  SOA   asgard.skynet.local. noreply.kongroo.anonaddy.com. ( 2020091025 7200 3600 1209600 3600 )
      skynet.local.   IN  NS    asgard
      skynet.local.   IN  NS    livebox
      tasmota-tv      IN  A     10.10.111.14
      tasmota-nas     IN  A     10.10.111.27
      tasmota-desk    IN  A     10.10.111.28
      tasmota-window  IN  A     10.10.111.29
      asgard          IN  A     10.10.111.100
                      IN  AAAA  2a01:cb1d:92dc:e500:2eda:d5e3:ab5:4a14
      home-assistant  IN  CNAME asgard
      yggdrasil       IN  A     10.10.111.101
      gallery         IN  CNAME yggdrasil
      smb             IN  CNAME yggdrasil
      njord           IN  A     10.10.111.26
                      IN  AAAA  2a01:e0a:2f9:f360:8c79:a3d5:e5c3:d4a8
                      IN  A     10.10.111.31
      baldur          IN  A     10.10.111.20
                      IN  A     10.10.111.21
      heimdall        IN  A     10.10.111.102
                      IN  AAAA  2a01:cb1d:92dc:e500:332b:ce0d:32f3:2c52
                      IN  A     10.10.111.43
      deluge          IN  CNAME heimdall
      jellyfin        IN  CNAME heimdall
      lidarr          IN  CNAME heimdall
      nzbget          IN  CNAME heimdall
      prowlarr        IN  CNAME heimdall
      radarr          IN  CNAME heimdall
      readarr         IN  CNAME heimdall
      sonarr          IN  CNAME heimdall
      kronos          IN  A     10.10.111.103
      thor            IN  A     10.10.111.104
      pi401           IN  A     10.10.111.123
      livebox         IN  A     10.10.111.254
    '';
  };

  networking.firewall = {
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

  tailscale = {
    advertisedRoutes = [ "10.10.111.0/24" ];
    exitNode = false;
    subnetRouter = true;
  };
}
