{ config, pkgs, username, ... }:
{
    sops.secrets."users/${username}/password".neededForUsers = true;

    users.users.${username} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "${username}";
      extraGroups = [ "wheel" "video" ];
      hashedPasswordFile = config.sops.secrets."users/${username}/password".path;
      openssh.authorizedKeys.keys = (import ./ssh.nix).keys;
    };
}
