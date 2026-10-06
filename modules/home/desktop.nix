{
  osConfig,
  lib,
  pkgs,
  inputs,
  isLinux,
  ...
}:
let
  cfg = osConfig.kp.desktop;
  nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  pkgsWithOverrides = pkgs.extend (
    prev: next: {
      signal-desktop = next.signal-desktop.overrideAttrs (old: {
        postInstall = ''
          wrapProgram $out/bin/signal-desktop \
            --add-flags "--use-tray-icon"
        '';
      });
    }
  );
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
        # Pinned: unstable isn't built for aarch64 yet, and the stable copy duplicates
        # parts of the Qt/python stack. Check with `just cached njord libreoffice`.
        nixpkgs-stable.libreoffice
        pkgsWithOverrides.signal-desktop
        vlc
      ]
      ++ lib.optionals osConfig.kp.apps.prusa-slicer.enable [ prusa-slicer ]
      ++ lib.optionals isLinux [
        brightnessctl
        playerctl
        pulseaudio
        xdg-utils
      ]
      ++ lib.optionals (isLinux && osConfig.kp.apps.wine.enable) [ wineWow64Packages.waylandFull ];
  };
}
