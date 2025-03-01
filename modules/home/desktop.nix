{ desktop, lib, pkgs, ... }:
{
  imports = lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland;

  config = lib.mkIf desktop.enable {
    home.packages = with pkgs; [
      # General desktop packages
      brightnessctl
      filezilla
      keepassxc
      # libreoffice
      mumble
      playerctl
      pulseaudio
      texlive.combined.scheme-full
      vlc
      xdg-utils
    ];
  };
}
