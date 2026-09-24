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
    impermanence.url = "github:nix-community/impermanence";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-stable-small.url = "github:NixOS/nixpkgs/nixos-26.05-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Neovim wrapped with its plugins, LSPs, TeX Live and zathura (modules/home/editor.nix)
    nvim = {
      url = "github:KongrooParadox/nvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.1.0";
    };
    # proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    proxmox-nixos.url = "github:KongrooParadox/proxmox-nixos/fix/pve-qemu-hash";
    sops-nix.url = "github:Mic92/sops-nix";
    steam-asahi = {
      url = "github:KongrooParadox/steam-asahi/feature/desktop-shortcuts";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    stylix-unstable = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    big-files = {
      flake = false;
      url = "github:KongrooParadox/big-files";
    };
  };

  outputs =
    {
      nix-darwin,
      nixpkgs-unstable,
      self,
      ...
    }@inputs:
    let
      inherit (nixpkgs-unstable) lib;
      inherit (self) outputs;
      facts = (import ./facts { inherit lib; }).facts;
      helpers = (import ./facts { inherit lib; }).helpers;
      mkHost =
        name:
        let
          baseModule = if facts.managedHosts.${name}.isLinux then ./modules/nixos else ./modules/nix-darwin;
          builder =
            if facts.managedHosts.${name}.isLinux then pkgs.lib.nixosSystem else nix-darwin.lib.darwinSystem;
          channel = "nixpkgs-${if facts.managedHosts.${name}.isUnstable then "unstable" else "stable"}${
            lib.optionalString facts.managedHosts.${name}.isSmall "-small"
          }";
          pkgs = inputs.${channel};
          site = helpers.siteOf name;
          domain = helpers.domainOf site;
          siteCfg = helpers.siteCfgOf site;
          sambaIp = facts.sambaIps.${site};
          gateway = helpers.ipv4AddressOf site "box";
          nameservers = helpers.nameserversIpv4AddressOf site;
          zone = helpers.zoneOf site;
        in
        builder {
          specialArgs = {
            host = name;
            inherit
              domain
              gateway
              inputs
              nameservers
              sambaIp
              self
              site
              zone
              ;
            inherit (siteCfg) dns subnet workgroup;
            inherit (facts.managedHosts.${name})
              isLinux
              isUnstable
              stateVersion
              users
              usesDisplaylink
              ;
          };
          modules = [ baseModule ];
        };
      buildAll = names: lib.genAttrs names (n: mkHost n);
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
    in
    {
      nixosConfigurations = buildAll facts.nixosHosts;
      darwinConfigurations = buildAll facts.darwinHosts;

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          zones = pkgs.runCommand "check-zones" { nativeBuildInputs = [ pkgs.bind ]; } ''
            ${lib.concatStrings (
              lib.mapAttrsToList (site: cfg: ''
                named-checkzone ${helpers.domainOf site} ${pkgs.writeText "${site}.zone" ''
                  $ORIGIN ${helpers.domainOf site}.
                  $TTL 300
                  @ IN SOA ns-check hostmaster ( 1 3600 900 604800 300 )
                  @ IN NS ns-check
                  ns-check IN A 127.0.0.1
                  ${helpers.zoneOf site}
                ''}
              '') facts.sites
            )}
            touch $out
          '';
        }
      );

      devShells = forAllSystems (system: {
        default = inputs.nixpkgs-unstable.legacyPackages.${system}.mkShellNoCC {
          packages = [ outputs.formatter.${system} ];
        };
      });

      formatter = inputs.nixpkgs-unstable.formatter;

      overlays = import ./overlays { inherit inputs; };
      homeModules.default = ./modules/home;
    };
}
