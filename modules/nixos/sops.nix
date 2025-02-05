{ inputs, username, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops {
      sops = {
        age = {
          sshKeyPaths = [
            "/home/${username}/.ssh/id_ed25519"
            "/etc/ssh/ssh_host_ed25519_key"
          ];
        };
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        secrets."acme-ovh" = {};
        secrets."tailscale/server-key" = {};
      };
    }
  ];
}
