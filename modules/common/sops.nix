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
      map (
        user:
        if isLinux then
          "/persist/home/${user}/.ssh/id_ed25519"
        else
          "/persist/Users/${user}/.ssh/id_ed25519"
      ) users
    else
      map (
        user: if isLinux then "/home/${user}/.ssh/id_ed25519" else "/Users/${user}/.ssh/id_ed25519"
      ) users
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
