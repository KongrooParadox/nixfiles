{
  config,
  inputs,
  lib,
  system,
  users,
  ...
}:
let
  isLinux = lib.strings.hasSuffix "linux" system;
  sopsKeyPath =
    if config.kp.impermanence.enable then
      map (user: "/persist${config.home.homeDirectory}/.ssh/id_ed25519") users
    else
      map (user: "${config.home.homeDirectory}/.ssh/id_ed25519") users
      ++ [
        "/etc/ssh/ssh_host_ed25519_key"
      ];
  module = if isLinux then inputs.sops-nix.nixosModules.sops else inputs.sops-nix.darwinModules.sops;
in
{
  imports = [
    module
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
