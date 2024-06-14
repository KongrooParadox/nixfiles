{
  description = "A nixos home-assistant image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inherit (pkgs) lib;

    baseModule = { lib, config, pkgs, ...}: {
      nixpkgs.hostPlatform = "aarch64-linux";
      imports = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
        ../../modules/home-assistant.nix
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

      environment.systemPackages = with pkgs; [
        tmux
        vim
      ];

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
        openssh.authorizedKeys.keys = [
          (builtins.readFile ~/.ssh/id_ed25519.pub)
        ];
      };

      networking = {
        hostName = "asgard";
        networkmanager.enable = true;
      };

      nix.settings = {
        trusted-users = [ "root" "ops" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      system.stateVersion = "24.05";
    };

    asgard = nixpkgs.lib.nixosSystem {
      modules = [baseModule];
    };

    make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
  in {
    inherit pkgs;
    nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
      modules = [baseModule];
      system = "aarch64-linux";
    };
    image = make-disk-image {
      inherit pkgs lib;
      config = asgard.config;
      name = "nixos-asgard";
      format = "qcow2";
      partitionTableType = "efi";
      copyChannel = false;
    };
  };
}
