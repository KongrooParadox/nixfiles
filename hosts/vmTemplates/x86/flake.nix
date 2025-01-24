{
  description = "A nixos cloudinit base image without nixos-infect";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inherit (pkgs) lib;

    baseModule = { lib, config, pkgs, ...}: {
      nixpkgs.hostPlatform = "x86_64-linux";
      imports = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];

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
        tmp.cleanOnBoot = true; growPartition = true;
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
        openssh.authorizedKeys.keys = (import ../../../modules/ssh.nix).keys;
      };

      networking = {
        networkmanager.enable = true;
        hostName = "nixos-cloudinit";
      };

      systemd.network.enable = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      system.stateVersion = "24.05";
    };

    nixos = nixpkgs.lib.nixosSystem {
      modules = [baseModule];
    };

    make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
  in {
    inherit pkgs;
    image = make-disk-image {
      inherit pkgs lib;
      config = nixos.config;
      name = "nixos-cloudinit";
      format = "qcow2";
      partitionTableType = "efi";
      copyChannel = false;
    };
  };
}
