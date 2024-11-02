{
  description = "Flake for my Mac Mini M1 hypervisor, aka Heimdall.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
  };

  outputs = { nixpkgs, apple-silicon, ... }: {

    nixosConfigurations.heimdall = nixpkgs.lib.nixosSystem {
      modules = [
        apple-silicon.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
