{
  description = "Flake for my Mac Mini M1 hypervisor, aka Heimdall.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { nixpkgs, apple-silicon, sops-nix, ... }: {

    nixosConfigurations.heimdall = nixpkgs.lib.nixosSystem {
      modules = [
        apple-silicon.nixosModules.default
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
        ../../modules/tailscale.nix {
          tailscale = {
            enable = true;
            ssh = true;
          };
        }
      ];
    };
  };
}
