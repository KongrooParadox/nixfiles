{ pkgs, ... }:

{

  imports = [
    ./homeManagerModules/browser.nix
    ./homeManagerModules/editor.nix
    ./homeManagerModules/git.nix
    ./homeManagerModules/hyprland.nix
    ./homeManagerModules/terminal.nix
  ];

  home.username = "robot";
  home.homeDirectory = "/home/robot";

  home.packages = with pkgs; [
    ansible
    ansible-lint
    cargo
    cliphist
    filezilla
    keepassxc
    libreoffice
    mako
    neofetch
    playerctl
    pulseaudio
    rofi
    rustc
    shotman
    starship
    texlive.combined.scheme-full
    wl-clipboard
    xdg-utils
  ];

  home.file = {
    "libvirt.conf" = {
      source = ./dotfiles/libvirt;
      target = ".config/libvirt";
    };
    "nvim" = {
      source = ./dotfiles/nvim;
      target = ".config/nvim";
      recursive = true;
    };
    "scripts" = {
      source = ./dotfiles/bin;
      target = ".local/bin";
    };
    ".ssh/config" = {
      source = ./dotfiles/ssh/config;
    };
  };

  home.stateVersion = "23.11";
# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
