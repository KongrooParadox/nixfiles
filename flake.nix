{
  description = "flake for my NixOS machines";

  inputs = {
    # apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    apple-silicon.url = "github:KongrooParadox/nixos-apple-silicon/zfs-kernel";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      apple-silicon,
      nixpkgs,
      nixpkgs-unstable,
      impermanence,
      nix-darwin,
      nix-ld,
      self,
      ...
    }@inputs:
    {
      darwinConfigurations = {
        njord-mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "njord-mac";
            users = [ "robot" ];
            stateVersion = "25.05";
            system = "aarch64-darwin";
            inherit self inputs;
          };
          modules = [
            ./modules/nix-darwin
          ];
        };
      };
      nixosConfigurations = {
        asgard = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "asgard";
            users = [ "ops" ];
            stateVersion = "24.05";
            system = "aarch64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        baldur = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "baldur";
            users = [
              "fatiha"
              "robot"
            ];
            stateVersion = "23.11";
            system = "x86_64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        heimdall = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "heimdall";
            users = [ "ops" ];
            stateVersion = "24.05";
            system = "aarch64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        iso-arm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "iso-arm";
            users = [ "ops" ];
            stateVersion = "25.05";
            system = "aarch64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        iso-x86 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "iso-x86";
            users = [ "ops" ];
            stateVersion = "25.05";
            system = "x86_64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        lordi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "lordi";
            users = [
              "fatiha"
              "robot"
            ];
            stateVersion = "25.05";
            system = "x86_64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        midgard = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            domain = "pernes.kongroo.ovh";
            host = "midgard";
            users = [ "ops" ];
            stateVersion = "24.11";
            system = "x86_64-linux";
            workgroup = "CASA_ANITA";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        njord = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "njord";
            users = [ "robot" ];
            stateVersion = "24.11";
            system = "aarch64-linux";
            workgroup = "SKYNET";
            inherit
              apple-silicon
              impermanence
              inputs
              nix-ld
              self
              ;
          };
          modules = [
            ./modules/nixos
          ];
        };
        vili = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            domain = "pernes.kongroo.ovh";
            host = "vili";
            users = [ "ops" ];
            stateVersion = "24.11";
            system = "aarch64-linux";
            workgroup = "CASA_ANITA";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        yggdrasil = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "yggdrasil";
            users = [ "ops" ];
            stateVersion = "24.05";
            system = "x86_64-linux";
            workgroup = "SKYNET";
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
      };
    };
}
