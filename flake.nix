{
  description = "flake for my NixOS machines";

  inputs = {
    # apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    apple-silicon.url = "github:KongrooParadox/nixos-apple-silicon/fairydust";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    impermanence.url = "github:nix-community/impermanence";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-muvm-steam.url = "github:dramforever/nixos-muvm-steam";
    nixpkgs-stable-small.url = "github:NixOS/nixpkgs/nixos-26.05-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
    };
    # proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    proxmox-nixos.url = "github:KongrooParadox/proxmox-nixos/fix/pve-qemu-hash";
    sops-nix.url = "github:Mic92/sops-nix";
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    wallpapers = {
      flake = false;
      url = "github:KongrooParadox/wallpapers";
    };
  };

  outputs =
    {
      apple-silicon,
      impermanence,
      nix-darwin,
      nix-ld,
      nixpkgs-unstable,
      self,
      ...
    }@inputs:
    let
      inherit (nixpkgs-unstable) lib;
      mkHost =
        name:
        {
          domain,
          users,
          workgroup,
          stateVersion,
          isLinux,
          isUnstable,
          isSmall,
          usesDisplaylink,
          extraModules,
          extraSpecialArgs,
        }:
        let
          channel = "nixpkgs-${
            if isUnstable then "unstable" else "stable"
          }${lib.optionalString isSmall "-small"}";
          pkgs = inputs.${channel};
          builder = if isLinux then pkgs.lib.nixosSystem else nix-darwin.lib.darwinSystem;
          baseModule = if isLinux then ./modules/nixos else ./modules/nix-darwin;
        in
        builder {
          specialArgs = {
            host = name;
            inherit
              domain
              users
              workgroup
              stateVersion
              isLinux
              isUnstable
              usesDisplaylink
              self
              impermanence
              inputs
              ;
          }
          // extraSpecialArgs;
          modules = [ baseModule ] ++ extraModules;
        };

      # Majority-case defaults; hosts declare only deviations.
      hostDefaults = {
        domain = "tavel.kongroo.ovh";
        users = [ "ops" ];
        workgroup = "SKYNET";
        isLinux = true;
        isUnstable = false;
        isSmall = false;
        usesDisplaylink = false;
        extraModules = [ ];
        extraSpecialArgs = { };
      };

      hosts = lib.mapAttrs (_: cfg: hostDefaults // cfg) {
        # Darwin
        njord-mac = {
          users = [ "robot" ];
          stateVersion = "25.05";
          isLinux = false;
          isUnstable = true;
          workgroup = null;
        };

        # NixOS: stable
        asgard = {
          domain = "pernes.kongroo.ovh";
          workgroup = "CASA_ANITA";
          stateVersion = "24.05";
        };
        box = {
          domain = "avignon.kongroo.ovh";
          workgroup = "BLANCHISSAGE";
          stateVersion = "26.05";
          isSmall = true;
        };
        elnuevo-1.stateVersion = "25.05";
        elnuevo-2.stateVersion = "25.05";
        iso-arm.stateVersion = "25.05";
        iso-x86.stateVersion = "25.05";
        lordi = {
          users = [
            "fatiha"
            "robot"
          ];
          stateVersion = "25.05";
          usesDisplaylink = true;
        };
        midgard = {
          domain = "pernes.kongroo.ovh";
          workgroup = "CASA_ANITA";
          stateVersion = "24.11";
        };
        vili.stateVersion = "25.11";
        yggdrasil.stateVersion = "24.05";

        # NixOS: unstable
        baldur = {
          users = [
            "fatiha"
            "robot"
          ];
          stateVersion = "23.11";
          isUnstable = true;
          usesDisplaylink = true;
        };
        heimdall = {
          stateVersion = "24.05";
          isUnstable = true;
        };
        njord = {
          users = [ "robot" ];
          stateVersion = "24.11";
          isUnstable = true;
          usesDisplaylink = true;
          extraSpecialArgs = { inherit apple-silicon nix-ld; };
        };
        oci-arm = {
          domain = "mrs-cloud.kongroo.ovh";
          workgroup = "OCI";
          stateVersion = "26.11";
          isUnstable = true;
          isSmall = true;
        };
      };

      platforms = lib.partition (n: hosts.${n}.isLinux) (builtins.attrNames hosts);
      buildAll = names: lib.genAttrs names (n: mkHost n hosts.${n});
    in
    {
      nixosConfigurations = buildAll platforms.right;
      darwinConfigurations = buildAll platforms.wrong;

      overlays = import ./overlays { inherit inputs; };
      homeManagerModules.default = ./modules/home;
    };
}
