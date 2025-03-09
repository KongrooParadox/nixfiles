{ inputs, users, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops {
      sops = {
        age = {
          sshKeyPaths =
            (builtins.concatMap (user: [ "/home/${user}/.ssh/id_ed25519" ]) users)
            ++ [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        secrets."acme-ovh" = {};
        secrets."tailscale/server-key" = {};
      };
    }
  ];
}
