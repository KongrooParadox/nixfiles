{
  desktop,
  lib,
  pkgs,
  inputs,
  isLinux,
  ...
}:
let
  nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports =
    lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland
    ++ lib.optional (desktop.enable && isLinux) ./tex.nix;

  config = lib.mkIf (desktop.enable && desktop.environment != "macos") {
    gtk.gtk4.theme = lib.mkForce null;
    home.packages =
      with pkgs;
      [
        # General desktop packages
        filezilla
        keepassxc
        nixpkgs-stable.libreoffice
        mpv
        mumble
        prusa-slicer
        pulseaudio
        signal-desktop
        vlc
      ]
      ++ lib.optionals isLinux [
        brightnessctl
        playerctl
        xdg-utils
        wineWow64Packages.waylandFull
      ];
  };
}
