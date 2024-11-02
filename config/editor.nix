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
    ansible-language-server
    bash-language-server
    docker-compose-language-service
    dockerfile-language-server-nodejs
    vscode-langservers-extracted
    gopls
    helm-ls
    lua-language-server
    nixd
    nixpkgs-fmt
    rust-analyzer
    terraform-ls
    typescript-language-server
    yaml-language-server
    python312Packages.python-lsp-server
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
