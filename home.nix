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
    ./homeManagerModules/emoji.nix
    ./homeManagerModules/git.nix
    ./homeManagerModules/hyprland.nix
    ./homeManagerModules/rofi.nix
    ./homeManagerModules/swaync.nix
    ./homeManagerModules/terminal.nix
    ./homeManagerModules/waybar.nix
    ./homeManagerModules/wlogout.nix
  ];

  stylix.targets.waybar.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = false;

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
    rustc
    shotman
    starship
    texlive.combined.scheme-full
    wl-clipboard
    xdg-utils
    (import ./scripts/emoji-picker.nix { inherit pkgs; })
    (import ./scripts/task-waybar.nix { inherit pkgs; })
    (import ./scripts/web-search.nix { inherit pkgs; })
    (import ./scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./scripts/screen-capture.nix { inherit pkgs; })
    (import ./scripts/list-hypr-bindings.nix { inherit pkgs; })
  ];

  home.stateVersion = "23.11";
# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
