{ pkgs, ... }:
let
  user = {
    email = "7790572+KongrooParadox@users.noreply.github.com";
    name = "Guillaume Nanty";
  };
  gpg = {
    program = "/run/current-system/sw/bin/gpg";
    key = "2CD046115D337861";
  };
in
{
  home.packages = [ pkgs.jjui ];
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        core = {
          editor = "nvim";
          autocrlf = false;
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          excludesfile = "~/.gitignore";
        };
        credential.helper = "cache";
        help.autocorrect = 20;
        init.defaultBranch = "main";
        user = user;
      };
      signing = {
        format = "openpgp";
        key = gpg.key;
        signByDefault = true;
        signer = gpg.program;
      };
      lfs.enable = true;
    };
    jujutsu = {
      enable = true;
      settings = {
        ui = {
          default-command = "status";
          paginate = "never";
        };
        user = user;
        signing = {
          backend = "gpg";
          backends.gpg.program = gpg.program;
          behavior = "own";
          key = gpg.key;
        };
      };
    };
  };
}
