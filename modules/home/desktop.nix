{
  osConfig,
  lib,
  pkgs,
  inputs,
  isLinux,
  ...
}:
let
  nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  cfg = osConfig.kp.desktop;
in
{
  imports = [
    ./hyprland
  ];

  config = lib.mkIf cfg.enable {
    gtk.gtk4.theme = lib.mkForce null;
    home.packages =
      with pkgs;
      [
        # General desktop packages
        filezilla
        keepassxc
        mpv
        mumble
        nixpkgs-stable.libreoffice
        prusa-slicer
        signal-desktop
        vlc
      ]
      ++ lib.optionals isLinux [
        brightnessctl
        playerctl
        pulseaudio
        wineWow64Packages.waylandFull
        xdg-utils
      ];
  };
}
