{
  description = "flake for my NixOS machines";

  inputs = {
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    # apple-silicon.url = "github:KongrooParadox/nixos-apple-silicon/kernel-6.12";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, self, ... }@inputs: {
    nixosConfigurations = {
      asgard = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          domain = "tavel.kongroo.ovh";
          host = "asgard";
          users = [ "ops" ];
          stateVersion = "24.05";
          workgroup = "SKYNET";
          inherit self inputs;
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
          users = [ "fatiha" "robot" ];
          stateVersion = "23.11";
          workgroup = "SKYNET";
          inherit self inputs;
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
          workgroup = "SKYNET";
          inherit self inputs;
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
          workgroup = "CASA_ANITA";
          inherit self inputs;
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
          workgroup = "SKYNET";
          inherit self inputs;
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
          workgroup = "CASA_ANITA";
          inherit self inputs;
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
          workgroup = "SKYNET";
          inherit self inputs;
        };
        modules = [
          ./modules/nixos
        ];
      };
    };
  };
}
