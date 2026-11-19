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
    k8s-nix-infra = {
      url = "git+ssh://git@gitlab.com/mirai-gadget-laboratory/k8s-nix/k8s-nix-infra.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixos-avf.url = "github:KongrooParadox/nixos-avf/nixos-unstable-support";
    nixpkgs-stable-small.url = "github:NixOS/nixpkgs/nixos-26.05-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Neovim wrapped with its plugins, LSPs, TeX Live and zathura (modules/home/editor.nix)
    nvim-wrapper = {
      url = "github:KongrooParadox/nvim-wrapper";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    proxmox-nixos.url = "github:KongrooParadox/proxmox-nixos/fix/pve-qemu-hash";
    sops-nix.url = "github:Mic92/sops-nix";
    steam-asahi = {
      url = "github:KongrooParadox/steam-asahi/feat/dual-backend";
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
    agent-platform = {
      url = "github:KongrooParadox/agent-platform/develop";
      # url = "path:/home/robot/src/agent-platform";
    };
    bc-250 = {
      # url = "github:TesseractCat/bc250-nixos";
      url = "github:KongrooParadox/bc250-nixos/develop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      factsModule = import ./facts { inherit lib; };
      facts = factsModule.facts;
      helpers = factsModule.helpers;
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
          # machineIp = helpers.ipv4AddressOf site name;
          nameservers = helpers.nameserversIpv4AddressOf site;
          zone = helpers.zoneOf site;
        in
        builder {
          specialArgs = {
            host = name;
            inherit
              domain
              gateway
              helpers
              inputs
              nameservers
              sambaIp
              self
              site
              zone
              ;
            inherit (siteCfg) dns subnet workgroup;
            inherit (facts.managedHosts.${name})
              ipv4
              isLinux
              isUnstable
              stateVersion
              users
              usesDisplaylink
              ;
            # sd-image is only needed for initial flashing or drive replacement.
            # Passed as a specialArg (not read from config) to avoid infinite
            # recursion between the option and the conditional import.
            sdImageEnable = false;
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
          piHosts = [
            "pi1"
            "pi2"
            "pi3"
          ];
          piPrivateCredentials = [
            "etcdServerKey"
            "apiserverEtcdKey"
            "apiserverKey"
            "controllerManagerKey"
            "schedulerKey"
            "apiserverKubeletKey"
            "frontProxyKey"
            "serviceAccountKey"
            "kubeletServerKey"
            "kubeletClientKey"
            "kubeProxyKey"
            "flannelKey"
            "addonManagerKey"
          ];
          piPublicCredentials = [
            "etcdCa"
            "etcdServerCert"
            "apiserverEtcdCert"
            "kubernetesCa"
            "apiserverCert"
            "controllerManagerCert"
            "schedulerCert"
            "apiserverKubeletCert"
            "frontProxyCert"
            "kubeletServerCert"
            "kubeletClientCert"
            "kubeProxyCert"
            "flannelCert"
            "addonManagerCert"
          ];
          piClusterServices = [
            "etcd"
            "kube-apiserver"
            "kube-controller-manager"
            "kube-scheduler"
            "kubelet"
            "kube-proxy"
            "flannel"
            "haproxy"
            "keepalived"
            "kubernetes-agenix-secrets"
          ];
          piHostConfigs = map (name: self.nixosConfigurations.${name}.config) piHosts;
        in
        {
          cluster-network =
            assert lib.all (
              cfg:
              cfg.cluster.enable
              && cfg.cluster.podCidr == "10.240.0.0/16"
              && cfg.cluster.serviceCidr == "10.241.0.0/16"
              && cfg.cluster.nodes.${cfg.networking.hostName}.interface == "end0"
              && cfg.cluster.secrets.provider == "agenix"
              &&
                builtins.sort builtins.lessThan (builtins.attrNames cfg.cluster.secrets.ageFiles)
                == builtins.sort builtins.lessThan (
                  piPrivateCredentials ++ lib.optionals (cfg.networking.hostName == "pi1") [ "bootstrapKey" ]
                )
              &&
                builtins.sort builtins.lessThan (builtins.attrNames cfg.cluster.secrets.publicFiles)
                == builtins.sort builtins.lessThan (
                  piPublicCredentials ++ lib.optionals (cfg.networking.hostName == "pi1") [ "bootstrapCert" ]
                )
              && !(builtins.hasAttr "adminKey" cfg.cluster.secrets.ageFiles)
              && lib.all builtins.pathExists (
                builtins.attrValues cfg.cluster.secrets.ageFiles
                ++ builtins.attrValues cfg.cluster.secrets.publicFiles
              )
            ) piHostConfigs;
            assert lib.all (
              cfg:
              lib.all (name: builtins.hasAttr name cfg.systemd.services) piClusterServices
              && (cfg.networking.hostName == "pi1" -> builtins.hasAttr "nix-oci" cfg.systemd.services)
              && (cfg.networking.hostName != "pi1" -> !builtins.hasAttr "nix-oci" cfg.systemd.services)
            ) piHostConfigs;
            pkgs.runCommand "check-pi-cluster-network" { } "touch $out";
          dhcp-facts =
            assert helpers.dhcpReservationsOf "pernes" == [ ];
            assert lib.all (reservation: builtins.elem reservation (helpers.staticIpv4AddressesOf "oujda")) (
              helpers.dhcpReservationsOf "oujda"
            );
            assert lib.all (address: builtins.elem address (helpers.staticIpv4AddressesOf "oujda")) [
              {
                name = "pi1";
                ipv4 = "192.168.2.41";
              }
              {
                name = "pi2";
                ipv4 = "192.168.2.42";
              }
              {
                name = "pi3";
                ipv4 = "192.168.2.43";
              }
              {
                name = "k8s";
                ipv4 = "192.168.2.40";
              }
            ];
            assert lib.all (reservation: builtins.elem reservation (helpers.dhcpReservationsOf "oujda")) [
              {
                name = "pi1";
                ipv4 = "192.168.2.41";
              }
              {
                name = "pi2";
                ipv4 = "192.168.2.42";
              }
              {
                name = "pi3";
                ipv4 = "192.168.2.43";
              }
            ];
            assert !(lib.any (reservation: reservation.name == "k8s") (helpers.dhcpReservationsOf "oujda"));
            assert helpers.ipv4AddressOf "oujda" "k8s" == "192.168.2.40";
            pkgs.runCommand "check-dhcp-facts" { } "touch $out";
          dhcp-reservations =
            pkgs.runCommand "check-dhcp-reservations"
              {
                nativeBuildInputs = [ pkgs.python3 ];
              }
              ''
                mkdir -p tests modules/nixos/dhcp-server
                cp ${./tests/test_dhcp_reservations.py} tests/test_dhcp_reservations.py
                cp ${./modules/nixos/dhcp-server/dhcp-reservations.py} modules/nixos/dhcp-server/dhcp-reservations.py
                python3 -m unittest discover -s tests -v
                touch $out
              '';
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
