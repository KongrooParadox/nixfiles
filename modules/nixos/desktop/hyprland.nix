{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.kp.desktop.enable && (config.kp.desktop.environment == "hyprland")) {
    environment.sessionVariables.AQ_DRM_DEVICES = lib.mkDefault "/dev/dri/card1";

    programs = {
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
      };
      hyprlock.enable = true;
      thunar.enable = true;
      xfconf.enable = true;
    };

    environment.systemPackages = with pkgs; [
      swaynotificationcenter
    ];

    services = {
      greetd = {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session --asterisks";
          };
        };
      };
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
      # Power profile services
      upower.enable = true;
      tuned.enable = true;
    };

    xdg.portal.configPackages = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };
}
