{ config, pkgs, users, ... }:
{
  sops.secrets = builtins.listToAttrs (
    map (user: {
      name = "users/${user}/password";
      value = { neededForUsers = true; };
      }) users
    ) // {
    "users/root/password".neededForUsers = true;
  };

  users.users = builtins.listToAttrs (
    map (user: {
      name = user;
      value = {
        isNormalUser = true;
        shell = pkgs.zsh;
        description = user;
        extraGroups = [ "wheel" "video" ];
        hashedPasswordFile = config.sops.secrets."users/${user}/password".path;
        openssh.authorizedKeys.keys = (import ./ssh.nix).keys;
      };
      }) users
  ) // {
    root = {
      hashedPasswordFile = config.sops.secrets."users/root/password".path;
      openssh.authorizedKeys.keys = (import ./ssh.nix).keys;
    };
  };
}
