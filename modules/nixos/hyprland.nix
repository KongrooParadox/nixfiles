{ config, inputs, lib, pkgs, username, ... }:
{
  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "hyprland")) {
    environment.sessionVariables.AQ_DRM_DEVICES = lib.mkDefault "/dev/dri/card0";

    programs = {
      light.enable = true;
      hyprland = {
        enable = true;
        package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      };
    };

    services = {
      greetd = {
        enable = true;
        vt = 3;
        settings = {
          default_session = {
            user = username;
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember-user-session --user-menu";
          };
        };
      };
    };

    xdg.portal.configPackages = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
  };
}
