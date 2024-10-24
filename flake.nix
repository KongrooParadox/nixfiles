{
  description = "flake for baldur";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, sops-nix, ... }@inputs: {
    nixosConfigurations.baldur = nixpkgs.lib.nixosSystem {
      system = "x86-64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/baldur/configuration.nix
        ./modules/stylix.nix
        "${nixpkgs}/nixos/modules/hardware/video/displaylink.nix"
        sops-nix.nixosModules.sops {
          sops = {
            age.keyFile = "/home/robot/.config/sops/age/keys.txt";
            defaultSopsFile = ./secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."wireguard/casa-anita" = {};
            secrets."wireguard/home" = {};
          };
        }
        inputs.stylix.nixosModules.stylix
        nixos-hardware.nixosModules.dell-inspiron-7405
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.robot = { ... } : { imports = [ ./hosts/baldur/home.nix ]; };
          };
        }
      ];
    };
  };
}
