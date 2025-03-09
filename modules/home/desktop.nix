{ config, desktop, lib, pkgs, ... }:
let
  currentArchitecture = config.nixpkgs.system;
in
{
  imports = lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland;

  config = lib.mkIf desktop.enable {
    home.packages = with pkgs; [
      # General desktop packages
      brightnessctl
      filezilla
      keepassxc
      mumble
      playerctl
      pulseaudio
      texlive.combined.scheme-full
      vlc
      xdg-utils
    ]++ lib.optionals (currentArchitecture == "x86_64-linux") [
      libreoffice
    ];
  };
}
