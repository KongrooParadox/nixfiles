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
  imports =
    lib.optional (desktop.enable && desktop.environment == "hyprland") ./hyprland
    ++ lib.optional (desktop.enable && lib.strings.hasSuffix "linux" currentArchitecture) ./tex.nix;

  config = lib.mkIf (desktop.enable && desktop.environment != "macos") {
    gtk.gtk4.theme = lib.mkForce null;
    home.packages =
      with pkgs;
      [
        # General desktop packages
        filezilla
        keepassxc
        libreoffice
        mpv
        mumble
        prusa-slicer
        pulseaudio
        signal-desktop
        vlc
      ]
      ++ lib.optionals (lib.strings.hasSuffix "linux" currentArchitecture) [
        brightnessctl
        playerctl
        xdg-utils
        wineWow64Packages.waylandFull
      ];
  };
}
