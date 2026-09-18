{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
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
    dns-server.enable = true;
    home-assistant.enable = true;
    tailscale = {
      acceptRoutes = true;
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
