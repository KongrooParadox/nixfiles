{
  description = "Flake for my Mac Mini M1 hypervisor, aka Heimdall.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
  };

  outputs = { nixpkgs, apple-silicon, ... }: {

    nixosConfigurations.heimdall = nixpkgs.lib.nixosSystem {
      modules = [
        apple-silicon.nixosModules.default
        ({ lib, pkgs, ... }: {
          config = {
            nixpkgs.config.allowUnfree = true;
            boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
            boot.initrd.kernelModules = [ ];
            boot.kernelModules = [ ];
            boot.extraModulePackages = [ ];

            hardware.asahi.extractPeripheralFirmware = false;
            fileSystems."/" =
            { device = "/dev/disk/by-uuid/5328e256-31a8-4bce-8d40-87babc7857af";
              fsType = "ext4";
            };

            fileSystems."/boot" =
            { device = "/dev/disk/by-uuid/83A5-1612";
              fsType = "vfat";
              options = [ "fmask=0022" "dmask=0022" ];
            };

            swapDevices = [ ];

            nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
            # Use the systemd-boot EFI boot loader.
            boot.loader = {
              systemd-boot.enable = true;
              efi.canTouchEfiVariables = true;
            };

            nix = {
              settings = {
                experimental-features = [ "nix-command" "flakes" ];
                auto-optimise-store = true;
              };
              gc = {
                automatic = true;
                dates = "weekly";
                options = "--delete-older-than 1m";
              };
            };

            networking = {
              hostName = "heimdall";
              networkmanager.enable = true;
              useDHCP = false;
              bridges = {
                "br0" = {
                  interfaces = [ "end0" ];
                };
              };
              interfaces."br0".useDHCP = true;
              wireless.iwd = {
                enable = true;
                settings.General.EnableNetworkConfiguration = true;
              };
            };

            # Set your time zone.
            time.timeZone = "Europe/Paris";

            i18n = {
              defaultLocale = "fr_FR.UTF-8";
              extraLocaleSettings = {
                LC_ADDRESS = "fr_FR.UTF-8";
                LC_IDENTIFICATION = "fr_FR.UTF-8";
                LC_MEASUREMENT = "fr_FR.UTF-8";
                LC_MONETARY = "fr_FR.UTF-8";
                LC_NAME = "fr_FR.UTF-8";
                LC_NUMERIC = "fr_FR.UTF-8";
                LC_PAPER = "fr_FR.UTF-8";
                LC_TELEPHONE = "fr_FR.UTF-8";
                LC_TIME = "fr_FR.UTF-8";
              };
            };

            # Define a user account. Don't forget to set a password with ‘passwd’.
            users.users.ops = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" "sudo" "libvirtd" ];
              packages = with pkgs; [
                tree
              ];
              openssh.authorizedKeys.keys = [
                (builtins.readFile ~/.ssh/id_ed25519.pub)
                (builtins.readFile ~/.ssh/id_work.pub)
              ];
            };
            security.sudo.wheelNeedsPassword = false;

            environment.systemPackages = with pkgs; [
              curl
              git
              terraform
              tmux
              vim
              virt-manager
              wget
            ];

            # Enable the OpenSSH daemon.
            services.openssh.enable = true;

            virtualisation.libvirtd = {
              enable = true;
              qemu = {
                package = pkgs.qemu;
                runAsRoot = true;
                swtpm.enable = true;
                ovmf = {
                  enable = true;
                  packages = [(pkgs.OVMF.override {
                    secureBoot = true;
                    tpmSupport = true;
                  }).fd];
                };
              };
            };
            system.stateVersion = "24.05";
          };
        })
      ];
    };
  };
}
