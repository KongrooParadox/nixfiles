{ pkgs, ... }:

{
  home.username = "robot";
  home.homeDirectory = "/home/robot";

  home.file = {
    "libvirt.conf" = {
      source = ./dotfiles/libvirt;
      target = ".config/libvirt";
    };
    ".config/nvim" = {
      source = ./dotfiles/nvim;
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

  imports = [
    ./homeManagerModules/browser.nix
    ./homeManagerModules/editor.nix
    ./homeManagerModules/git.nix
    ./homeManagerModules/hyprland.nix
    ./homeManagerModules/terminal.nix
  ];

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

  home.stateVersion = "23.11";
# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
