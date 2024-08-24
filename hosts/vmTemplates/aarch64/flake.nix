{
  description = "A nixos cloudinit base image without nixos-infect";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
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
        openssh.authorizedKeys.keys = [
          (builtins.readFile ~/.ssh/id_ed25519.pub)
          (builtins.readFile ~/.ssh/id_work.pub)
        ];
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

      services.cloud-init = {
        enable = true;
        network.enable = true;
        config = ''
          system_info:
            distro: nixos
            network:
              renderers: [ 'networkd' ]
            default_user:
              name: ops
          users:
              - default
          ssh_pwauth: true
          chpasswd:
            expire: false
          cloud_init_modules:
            - bootcmd
            - write-files
            - growpart
            - resizefs
            - update_hostname
          cloud_config_modules:
            - disk_setup
            - mounts
            - set-passwords
            - runcmd
          runcmd:
            - sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix | sudo tee -a /tmp/runcmd.log;sudo reboot now'
        '';
      };

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
      copyChannel = true;
    };
  };
}
