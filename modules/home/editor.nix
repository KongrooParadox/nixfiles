{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  options.kp.emacs = {
    enable = lib.mkEnableOption "Emacs";
  };

  imports = [
    inputs.nix-doom-emacs-unstraightened.homeModule
    inputs.nvim-wrapper.homeModules.default
  ];

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

    home.packages = [
      pkgs.just
      pkgs.obsidian
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      # for nixd to source host-specific options in nvim config
      NIXFILES_DIR = "${config.home.homeDirectory}/nixfiles";
    };

    # Plugins, LSPs, TeX Live (vimtex) and zathura all come with the wrapper;
    # it also provides the vi, vim and vimdiff commands.
    wrappers.neovim = {
      enable = true;
      # Editable checkout of the config, searched by <leader>sn (falls back to
      # the store copy when missing).
      info.config_checkout = "${config.home.homeDirectory}/src/nvim-wrapper";
      settings.profile = if osConfig.kp.desktop.enable then "slim" else "light";
      # kulala-core is only packaged on unstable. specWith only reads a set as a
      # spec when it has `data`; mkIf false adds no definition.
      specs.kulala = lib.mkIf (!(pkgs ? kulala-core)) {
        enable = false;
        data = lib.mkIf false null;
      };
    };

    programs = {
      doom-emacs = {
        enable = config.kp.emacs.enable;
        doomDir = ../../dotfiles/doom.d;
        # Currently broken
        # doomDir = "${config.home.homeDirectory}/.config/doom.d";
        # doomDir = "/nix/store/3z230glrjqibydmxv1v2r612jv8bn3pj-home-manager-files/.config/doom.d";
      };
    };

    services.emacs = {
      enable = config.kp.emacs.enable;
    };

    stylix.targets.neovim.enable = false;
  };
}
