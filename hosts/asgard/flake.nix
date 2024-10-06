{
  description = "A nixos home-assistant image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ../../modules/home-assistant.nix
        ../../modules/dns-server.nix
        ./configuration.nix
        ];

    };
  };
}
