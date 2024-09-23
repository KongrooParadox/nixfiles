{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Guillaume Nanty";
      userEmail = "7790572+KongrooParadox@users.noreply.github.com";
      signing = {
        signByDefault = true;
        gpgPath = "/run/current-system/sw/bin/gpg";
        key = "E1FFAC5C39F79113";
      };
      lfs.enable = true;
      extraConfig = {
        core = {
          editor = "nvim";
          autocrlf = false;
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          excludesfile = "~/.gitignore";
        };
        help.autocorrect = 20;
        init.defaultBranch = "main";
        credential.helper = "cache";
      };
    };
  };
}
