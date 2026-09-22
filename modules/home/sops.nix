{
  config,
  inputs,
  osConfig,
  users,
  ...
}:
let
  sopsKeyPath =
    if osConfig.kp.impermanence.enable then
      map (user: "/persist${config.home.homeDirectory}/.ssh/id_ed25519") users
    else
      map (user: "${config.home.homeDirectory}/.ssh/id_ed25519") users;
in
{
  imports = [
    inputs.sops-nix.homeModules.sops
  ];

  config = {
    sops = {
      age = {
        sshKeyPaths = sopsKeyPath;
      };
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
    };
  };
}
