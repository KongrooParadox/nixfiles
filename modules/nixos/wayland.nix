{ config, inputs, lib, pkgs, username, ... }:
{
  config = lib.mkIf config.desktop.enable {
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
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
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
