{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixfiles/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  imports = [
    ./browser.nix
    ./desktop.nix
    ./editor.nix
    ./git.nix
    ./pentest.nix
    ./rclone.nix
    ./terminal.nix
  ];

  xdg.configFile = {
    "btop/themes" = {
      source = mkSymlink "${dotfiles}/btop/";
    };
    "doom.d" = {
      source = mkSymlink "${dotfiles}/doom.d/";
    };
    "k9s" = {
      source = mkSymlink "${dotfiles}/k9s/";
    };
    "libvirt" = {
      source = mkSymlink "${dotfiles}/libvirt/";
    };
    "nvim" = {
      source = mkSymlink "${dotfiles}/nvim";
    };
    "quickshell" = {
      source = mkSymlink "${dotfiles}/quickshell";
    };
    "tmux" = {
      source = mkSymlink "${dotfiles}/tmux";
    };
  };

  home = {
    file = {
      "scripts" = {
        source = mkSymlink "${dotfiles}/bin/";
        target = ".local/bin";
      };
      ".ssh/config" = {
        source = mkSymlink "${dotfiles}/ssh/config/";
      };
      ".w3m" = {
        source = mkSymlink "${dotfiles}/w3m/";
      };
    };

    packages = with pkgs; [
      ansible
      # ansible-lint
      cargo
      neofetch
      rustc
      starship
    ];
  };
}
