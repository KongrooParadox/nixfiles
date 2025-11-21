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

  kp = {
    dns-server = {
      enable = true;
      localDomain = "casa-anita.local";
      zone = ''
        $ORIGIN casa-anita.local.
        $TTL 3600 ; default expiration time (in seconds) of all RRs without their own TTL value
        casa-anita.local.  IN  SOA   asgard.casa-anita.local. noreply.kongroo.anonaddy.com. ( 2020091025 7200 3600 1209600 3600 )
        casa-anita.local.  IN  NS    asgard
        casa-anita.local.  IN  NS    livebox
        asgard             IN  A     192.168.1.100
        home-assistant     IN  CNAME asgard
        midgard            IN  A     192.168.1.101
        deluge             IN  CNAME midgard
        gallery            IN  CNAME midgard
        jellyfin           IN  CNAME midgard
        lidarr             IN  CNAME midgard
        nzbget             IN  CNAME midgard
        prowlarr           IN  CNAME midgard
        radarr             IN  CNAME midgard
        readarr            IN  CNAME midgard
        sonarr             IN  CNAME midgard
        livebox            IN  A     192.168.1.1
      '';
    };
    home-assistant.enable = true;
    tailscale = {
      acceptRoutes = true;
      advertisedRoutes = [ "192.168.1.0/24" ];
      exitNode = false;
      subnetRouter = true;
    };
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
}
