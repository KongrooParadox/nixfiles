{ config, desktop, lib, pkgs, ... }:
let
  currentArchitecture = config.nixpkgs.system;
in
{
  imports = lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland;

  config = lib.mkIf (desktop.enable && desktop.environment != "macos") {
    home.packages = with pkgs; [
      # General desktop packages
      filezilla
      keepassxc
      mumble
      prusa-slicer
      pulseaudio
      vlc
    ]++ lib.optionals (currentArchitecture == "x86_64-linux") [
      libreoffice
    ]++ lib.optionals (lib.strings.hasSuffix "linux" currentArchitecture) [
      brightnessctl
      playerctl
      texlive.combined.scheme-full
      xdg-utils
    ];
  };
}
