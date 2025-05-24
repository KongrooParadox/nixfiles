{
  config,
  inputs,
  lib,
  pkgs,
  users,
  ...
}:
{
  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "hyprland")) {
    environment.sessionVariables.AQ_DRM_DEVICES = lib.mkDefault "/dev/dri/card0";

    programs = {
      light.enable = true;
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      };
      thunar.enable = true;
      xfconf.enable = true;
    };

    environment.systemPackages = with pkgs; [
      swaynotificationcenter
    ];

    services = {
      greetd = {
        enable = true;
        vt = 3;
        settings = {
          default_session = {
            user = lib.lists.head users; # First user in list is the default
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember";
          };
        };
      };
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
    };

    xdg.portal.configPackages = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };
}
