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
    home.packages =
      with pkgs;
      [
        # General desktop packages
        filezilla
        keepassxc
        mumble
        prusa-slicer
        pulseaudio
        signal-desktop
        vlc
      ]
      ++ lib.optionals (currentArchitecture == "x86_64-linux") [
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
