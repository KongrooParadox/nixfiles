{
  gateway,
  helpers,
  host,
  ipv4,
  lib,
  subnet,
  ...
}:
let
  interface = helpers.dhcpServerInterfaceOf host;
  prefixLength = builtins.fromJSON (builtins.elemAt (lib.splitString "/" subnet) 1);
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  networking = {
    defaultGateway = {
      address = gateway;
      inherit interface;
    };
    interfaces.${interface} = {
      ipv4.addresses = [
        {
          address = ipv4;
          inherit prefixLength;
        }
      ];
      useDHCP = false;
    };
  };

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
    dhcp-server.enable = true;
    networking.networkmanager.useDHCP = false;
    dns-server.enable = true;
    home-assistant.enable = true;
    tailscale = {
      autoconnect = true;
      exitNode = false;
      subnetRouter = true;
    };
  };
}
