{
  description = "A nixos home-assistant image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix }: {
    nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."acme-ovh" = {};
          };
        }
        ../../modules/home-assistant.nix
        ../../modules/dns-server.nix
        ./configuration.nix
        ];

    };
  };
}
