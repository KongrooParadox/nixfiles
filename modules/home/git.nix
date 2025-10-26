{ pkgs, ... }:
{
  home.packages = [ pkgs.jjui ];
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "Guillaume Nanty";
      userEmail = "7790572+KongrooParadox@users.noreply.github.com";
      signing = {
        signByDefault = true;
        signer = "/run/current-system/sw/bin/gpg";
        key = "2CD046115D337861";
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
    jujutsu = {
      enable = true;
      settings = {
        ui = {
          default-command = "log";
          paginate = "never";
        };
        user = {
          email = "7790572+KongrooParadox@users.noreply.github.com";
          name = "Guillaume Nanty";
        };
        signing = {
          backend = "gpg";
          backends.gpg.program = "/run/current-system/sw/bin/gpg";
          behavior = "own";
          key = "2CD046115D337861";
        };
      };
    };
  };
}
