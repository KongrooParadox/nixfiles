{
  description = "flake for njord : m2 laptop";

  inputs = {
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    stylix.url = "github:danth/stylix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { apple-silicon, nixpkgs, home-manager, sops-nix, ... }@inputs: {
    nixosConfigurations.njord = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ../../modules/stylix.nix
        apple-silicon.nixosModules.default
        "${nixpkgs}/nixos/modules/hardware/video/displaylink.nix"
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/home/robot/.ssh/id_ed25519" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."wireguard/casa-anita" = {};
            secrets."wireguard/home" = {};
          };
        }
        inputs.stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.robot = { ... } : { imports = [ ./home.nix ]; };
          };
        }
      ];
    };
  };
}
