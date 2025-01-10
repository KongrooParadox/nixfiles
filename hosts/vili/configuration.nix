{ lib, pkgs, ...}:
{
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
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        device = lib.mkDefault "/dev/vda";
      };
    };
  };

  services.openssh.enable = true;

  services.qemuGuest.enable = true;

  security.sudo.wheelNeedsPassword = false;

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../modules/ssh.nix).keys;
  };

  services.resolved.enable = false;
  networking.nameservers = [ "127.0.0.1" ]; # Use local DNS server

  networking = {
    networkmanager = {
      enable = true;
      dns = "none"; # Prevent NetworkManager from managing resolv.conf
    };
    hostName = "vili";
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

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "ops" ];
    };
  };

  system.stateVersion = "24.11";
}
