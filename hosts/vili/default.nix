{ host, lib, modulesPath, pkgs, ...}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  reverseProxy.enable = true;
  home-assistant = {
    enable = true;
    hostname = "${host}.pernes.kongroo.ovh";
  };

  dns-server = {
    enable = true;
    publicDomain = "pernes.kongroo.ovh";
    localDomain = "casa-anita.local";
    mapping = {
      "vili.casa-anita.local" = "192.168.1.100";
      "midgard.casa-anita.local" = "192.168.1.101";
    };
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
