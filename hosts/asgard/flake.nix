{
  description = "Home-assistant & DNS server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix }: {
    nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."acme-ovh" = {};
            secrets."tailscale/server-key" = {};
          };
        }
        ../../modules/home-assistant.nix {
          home-assistant = {
            enable = true;
            hostname = "asgard.tavel.kongroo.ovh";
            acme.domain = "tavel.kongroo.ovh";
          };
        }
        ../../modules/dns-server.nix {
          dns-server = {
            enable = true;
            publicDomain = "tavel.kongroo.ovh";
            localDomain = "skynet.local";
            mapping = {
              "tasmota-desk.skynet.local" = "10.10.111.28";
              "tasmota-window.skynet.local" = "10.10.111.29";
              "tasmota-nas.skynet.local" = "10.10.111.27";
              "tasmota-tv.skynet.local" = "10.10.111.14";
              "njord.skynet.local" = "10.10.111.26,10.10.111.31";
              "baldur.skynet.local" = "10.10.111.20,10.10.111.21,2a01:cb1d:824f:1000:7f0b:431c:2066:a6ce";
              "asgard.skynet.local" = "10.10.111.100,2a01:cb1d:824f:1000:44a0:293a:69fa:1c5f";
              "yggdrasil.skynet.local" = "10.10.111.101,2a01:cb1d:824f:1000:24d1:69f:4b2c:78b9";
              "heimdall.skynet.local" = "10.10.111.102";
              "kronos.skynet.local" = "10.10.111.103";
              "thor.skynet.local" = "10.10.111.104";
              "livebox.skynet.local" = "10.10.111.254";
            };
          };
        }
        ../../modules/tailscale.nix {
          tailscale = {
            enable = true;
            advertisedRoutes = [ "10.10.111.0/24" ];
            exitNode = false;
            ssh = true;
            subnetRouter = true;
          };
        }
        ./configuration.nix
        ];

    };
  };
}
