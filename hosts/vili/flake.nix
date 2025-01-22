{
  description = "DNS server & Home assistant instance for Pernes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, sops-nix}: {
    nixosConfigurations.vili = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
        ./configuration.nix
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
        ../../modules/reverseProxy.nix
        ../../modules/home-assistant.nix {
          home-assistant = {
            enable = true;
            hostname = "vili.pernes.kongroo.ovh";
          };
        }
        ../../modules/dns-server.nix {
          dns-server = {
            enable = true;
            publicDomain = "pernes.kongroo.ovh";
            localDomain = "casa-anita.local";
            mapping = {
              "vili.casa-anita.local" = "192.168.1.100";
              "midgard.casa-anita.local" = "192.168.1.101";
            };
          };
        }
        ../../modules/tailscale.nix {
          tailscale = {
            enable = true;
            acceptRoutes = true;
            advertisedRoutes = [ "192.168.1.0/24" ];
            exitNode = false;
            ssh = true;
            subnetRouter = true;
          };
        }
      ];
    };
  };
}
