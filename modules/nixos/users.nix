{ pkgs, username, ... }:
{
    users.users.${username} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "${username}";
      extraGroups = [ "wheel" "video" ];
      openssh.authorizedKeys.keys = (import ./ssh.nix).keys;
    };
}
