{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs = inputs@{ self, sops-nix, nixpkgs, ... }: {
    nixosConfigurations.midgard = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        inputs.disko.nixosModules.disko
        ./hardware-configuration.nix
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            validateSopsFiles = false;
            secrets."acme-ovh" = {};
            secrets."zfs-dataset/midgard/root.key" = {};
            secrets."zfs-dataset/midgard/rust.key" = {};
            secrets."tailscale/server-key" = {};
          };
        }
        ../../modules/tailscale.nix {
          tailscale = {
            enable = true;
            acceptRoutes = false;
            ssh = true;
            exitNode = false;
            subnetRouter = false;
          };
        }
        ./disko.nix
        ../../modules/reverseProxy.nix
        ../../modules/immich.nix {
          immich = {
            enable = true;
            hostname = "midgard.pernes.kongroo.ovh";
          };
        }
      ];
    };
  };
}
