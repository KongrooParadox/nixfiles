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
    nixosConfigurations.yggdrasil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        inputs.disko.nixosModules.disko
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."acme-ovh" = {};
            secrets."zfs-dataset/yggdrasil/root.key" = {};
            secrets."zfs-dataset/yggdrasil/fast.key" = {};
            secrets."zfs-dataset/yggdrasil/rust.key" = {};
            secrets."tailscale/server-key" = {};
          };
        }
        ../../modules/tailscale.nix {
          tailscale = {
            enable = true;
            ssh = true;
            subnetRouter = false;
          };
        }
        ./disko.nix
        ../../modules/reverseProxy.nix
        ../../modules/immich.nix {
          immich = {
            enable = true;
            hostname = "yggdrasil.tavel.kongroo.ovh";
          };
        }
        ../../modules/arr.nix {
          arr = {
            enable = true;
            hostname = "yggdrasil.tavel.kongroo.ovh";
          };
        }
        ../../modules/storage.nix
      ];
    };
  };
}
