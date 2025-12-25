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
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    proxmox-nixos.url = "github:KongrooParadox/proxmox-nixos/fix/pve-qemu-hash";
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      apple-silicon,
      nixpkgs-stable,
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
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "njord-mac";
            users = [ "robot" ];
            stateVersion = "25.05";
            isUnstable = true;
            isLinux = false;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nix-darwin
          ];
        };
      };
      nixosConfigurations = {
        asgard = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "pernes.kongroo.ovh";
            host = "asgard";
            users = [ "ops" ];
            stateVersion = "24.05";
            workgroup = "CASA_ANITA";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        baldur = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "baldur";
            users = [
              "fatiha"
              "robot"
            ];
            stateVersion = "23.11";
            workgroup = "SKYNET";
            isUnstable = true;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        elnuevo-1 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "elnuevo-1";
            users = [ "ops" ];
            stateVersion = "25.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        elnuevo-2 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "elnuevo-2";
            users = [ "ops" ];
            stateVersion = "25.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        heimdall = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "heimdall";
            users = [ "ops" ];
            stateVersion = "24.05";
            workgroup = "SKYNET";
            isUnstable = true;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        iso-arm = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "iso-arm";
            users = [ "ops" ];
            stateVersion = "25.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        iso-x86 = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "iso-x86";
            users = [ "ops" ];
            stateVersion = "25.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        lordi = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "lordi";
            users = [
              "fatiha"
              "robot"
            ];
            stateVersion = "25.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        midgard = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "pernes.kongroo.ovh";
            host = "midgard";
            users = [ "ops" ];
            stateVersion = "24.11";
            workgroup = "CASA_ANITA";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
        njord = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "njord";
            users = [ "robot" ];
            stateVersion = "24.11";
            workgroup = "SKYNET";
            isUnstable = true;
            isLinux = true;
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
        yggdrasil = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            domain = "tavel.kongroo.ovh";
            host = "yggdrasil";
            users = [ "ops" ];
            stateVersion = "24.05";
            workgroup = "SKYNET";
            isUnstable = false;
            isLinux = true;
            inherit self impermanence inputs;
          };
          modules = [
            ./modules/nixos
          ];
        };
      };
      overlays = import ./overlays { inherit inputs; };
      homeManagerModules.default = ./modules/home;
    };
}
