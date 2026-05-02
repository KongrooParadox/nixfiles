{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kp.emacs = {
    enable = lib.mkEnableOption "Emacs";
  };

  config = {
    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          end_of_line = "lf";
          insert_final_newline = true;
          trim_trailing_whitespace = true;
          charset = "utf-8";
          indent_style = "space";
          indent_size = 4;
        };
        "Makefile" = {
          indent_style = "tab";
        };
        "*.{nix,yaml,yml,tf,lua}" = {
          indent_size = 2;
        };
        "*.md" = {
          indent_size = 2;
          trim_trailing_whitespace = false;
        };
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg: true;

    home.packages = with pkgs; [
      # ansible-language-server #unmaintained in nixpkgs
      bash-language-server
      docker-compose-language-service
      dockerfile-language-server
      gopls
      helm-ls
      just
      just-formatter
      just-lsp
      lua-language-server
      llvmPackages_20.clang-unwrapped
      nixd
      nil
      nixfmt
      python313Packages.python-lsp-server
      rust-analyzer
      terraform
      terraform-ls
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];

    programs = {
      doom-emacs = {
        enable = config.kp.emacs.enable;
        doomDir = ../../dotfiles/doom.d;
        # Currently broken
        # doomDir = "${config.home.homeDirectory}/.config/doom.d";
        # doomDir = "/nix/store/3z230glrjqibydmxv1v2r612jv8bn3pj-home-manager-files/.config/doom.d";
      };
      neovim = {
        defaultEditor = true;
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withPython3 = false;
        withRuby = false;
      };
    };

    services.emacs = {
      enable = config.kp.emacs.enable;
    };

    stylix.targets.neovim.enable = false;
  };
}
