{ config, desktop, lib, pkgs, ... }:
{
  config = lib.mkIf desktop.enable {
    home.packages = with pkgs; [
      brightnessctl
      cliphist
      filezilla
      keepassxc
      # libreoffice
      mumble
      playerctl
      pulseaudio
      texlive.combined.scheme-full
      vlc
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
  };
}
