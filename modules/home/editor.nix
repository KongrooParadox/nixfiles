{ pkgs, ... }:

{
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
      "*.{nix,yaml,yml,tf}" = {
        indent_size = 2;
      };
      "*.md" = {
        indent_size = 2;
        trim_trailing_whitespace = false;
      };
    };
  };

  home.packages = with pkgs; [
    alejandra
    ansible-language-server
    bash-language-server
    docker-compose-language-service
    dockerfile-language-server-nodejs
    gopls
    helm-ls
    lua-language-server
    nixd
    nixfmt-rfc-style
    nixpkgs-fmt
    python312Packages.python-lsp-server
    rust-analyzer
    terraform
    terraform-ls
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
  ];

  programs = {
    neovim = {
      defaultEditor = true;
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
  };

}
