{
  config,
  inputs,
  users,
  ...
}:
let
  sopsKeyPath =
    if config.kp.impermanence.enable then
      map (user: "/persist/home/${user}/.ssh/id_ed25519") users
    else
      map (user: "/home/${user}/.ssh/id_ed25519") users
      ++ [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    {
      sops = {
        age = {
          sshKeyPaths = sopsKeyPath;
        };
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
      };
    }
  ];
}
