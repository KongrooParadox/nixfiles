{
  # https://myme.no/posts/2022-12-01-nixos-on-raspberrypi.html
  description = "NixOS Raspberry Pi configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };
  outputs = { self, nixpkgs}: {
    nixosConfigurations.rpi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ({ pkgs, ... }: {
          config = {
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              trusted-users = [
                "root"
                "@wheel"
              ];
            };
            environment.systemPackages = with pkgs; [
              tmux
              vim
            ];
            boot.loader = {
              grub.enable = false;  # GRUB is used by default, turn that off
              generic-extlinux-compatible.enable = true;
            };
            services = {
              openssh.enable = true;
              mosquitto = {
                enable = true;
                listeners = [
                  {
                    users.mosquitto = {
                      acl = [
                        "readwrite #"
                      ];
                      hashedPassword = "$7$101$zZowRHVB/HcjcgnJ$q4L1Vgw+riu3UBpBpjSPzS6P0hOrodx/bf1lWqEH5TR0aqYz2sl71eG04ksY/II98rGi1kFHndS9O3KsNLrbtw==";
                    };
                  }
                ];
              };
              home-assistant = {
                enable = true;
                extraComponents = [
                  # Components required to complete the onboarding
                  "esphome"
                  "met"
                  "radio_browser"
                  "mqtt"
                  "tasmota"
                  "google_translate"
                ];
                config = {
                  # Includes dependencies for a basic setup
                  # https://www.home-assistant.io/integrations/default_config/
                  default_config = {};
                  mqtt = {};
                  # tasmota = {
                  #   enabled = true;
                  # };
                };
              };
            };
            security.sudo.wheelNeedsPassword = false;
            networking = {
              hostName = "nix-pi301";
              firewall.allowedTCPPorts = [
                1883
                8123
              ];
              networkmanager.enable = true;
            };
            nixpkgs.config.permittedInsecurePackages = [
              "openssl-1.1.1w"
            ];
            system = {
              build.sdImage.compressImage = false;
              stateVersion = "24.05";
            };
            users.users.ops = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINS3jmx5Dy2UZufV4QBCOs+ok6gEW9sbmRPFQibv1Lbg robot@baldur-nix"
              ];
            };
          };
        })
      ];
    };
  };
}
