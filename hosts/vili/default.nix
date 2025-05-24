{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  reverseProxy.enable = true;
  home-assistant = {
    enable = true;
  };

  dns-server = {
    enable = true;
    localDomain = "casa-anita.local";
    zone = ''
      $ORIGIN casa-anita.local.
      $TTL 3600 ; default expiration time (in seconds) of all RRs without their own TTL value
      casa-anita.local.  IN  SOA   vili.casa-anita.local. noreply.kongroo.anonaddy.com. ( 2020091025 7200 3600 1209600 3600 )
      casa-anita.local.  IN  NS    vili
      casa-anita.local.  IN  NS    freebox
      vili               IN  A     192.168.1.100
                         IN  AAAA  2a01:e0a:2f9:f360:a581:82c2:9906:f301
      home-assistant     IN  CNAME vili
      midgard            IN  A     192.168.1.101
                         IN  AAAA  2a01:e0a:2f9:f360:7656:3cff:feaf:217f
      deluge             IN  CNAME midgard
      gallery            IN  CNAME midgard
      jellyfin           IN  CNAME midgard
      lidarr             IN  CNAME midgard
      nzbget             IN  CNAME midgard
      prowlarr           IN  CNAME midgard
      radarr             IN  CNAME midgard
      readarr            IN  CNAME midgard
      sonarr             IN  CNAME midgard
      svrmmd             IN  A     192.168.1.128
      freebox            IN  A     192.168.1.254
    '';
  };

  tailscale = {
    acceptRoutes = true;
    advertisedRoutes = [ "192.168.1.0/24" ];
    exitNode = false;
    subnetRouter = true;
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  fileSystems = {
    "/boot" = {
      label = "esp";
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
    "/" = {
      label = "nixos";
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    loader = {
      grub = {
        device = lib.mkDefault "/dev/vda";
      };
    };
  };

  services.openssh.enable = true;

  services.qemuGuest.enable = true;
  services.resolved.enable = false;
  networking.nameservers = [ "127.0.0.1" ]; # Use local DNS server

  networking = {
    networkmanager = {
      enable = true;
      dns = "none"; # Prevent NetworkManager from managing resolv.conf
    };
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
  };

  systemd.services.ethtool-config = {
    description = "Configure ethtool UDP GRO forwarding";
    after = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.ethtool}/bin/ethtool -K enp0s3 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
