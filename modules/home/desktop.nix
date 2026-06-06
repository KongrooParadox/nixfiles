{
  desktop,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  currentArchitecture = specialArgs.nixosConfig.nixpkgs.hostPlatform.system;
in
{
  imports = lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland;

  config = lib.mkIf (desktop.enable && desktop.environment != "macos") {
    gtk.gtk4.theme = lib.mkForce null;
    home.packages =
      with pkgs;
      [
        # General desktop packages
        filezilla
        keepassxc
        # mpv
        mumble
        prusa-slicer
        pulseaudio
        signal-desktop
        vlc
        libreoffice
      ]
      ++ lib.optionals (lib.strings.hasSuffix "linux" currentArchitecture) [
        brightnessctl
        playerctl
        texlive.combined.scheme-full
        xdg-utils
      ];
  };
}
