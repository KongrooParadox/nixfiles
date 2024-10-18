{ pkgs, ... }:

{
  home.username = "robot";
  home.homeDirectory = "/home/robot";

  home.file = {
    "libvirt.conf" = {
      source = ../../dotfiles/libvirt;
      target = ".config/libvirt";
    };
    ".config/nvim" = {
      source = ../../dotfiles/nvim;
      recursive = true;
    };
    "scripts" = {
      source = ../../dotfiles/bin;
      target = ".local/bin";
    };
    ".ssh/config" = {
      source = ../../dotfiles/ssh/config;
    };
  };

  imports = [
    ../../config/browser.nix
    ../../config/editor.nix
    ../../config/emoji.nix
    ../../config/git.nix
    ../../config/hyprland.nix
    ../../config/rofi.nix
    ../../config/swaync.nix
    ../../config/terminal.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
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
    (import ../../scripts/emoji-picker.nix { inherit pkgs; })
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/web-search.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../../scripts/rofi-clipboard-history.nix { inherit pkgs; })
    (import ../../scripts/screen-capture.nix { inherit pkgs; })
    (import ../../scripts/list-hypr-bindings.nix { inherit pkgs; })
    (import ../../scripts/waybar-launcher.nix { inherit pkgs; })
  ];

  home.stateVersion = "23.11";
# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
