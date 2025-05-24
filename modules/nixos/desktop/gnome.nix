{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "gnome")) {
    services = {
      gnome.gnome-browser-connector.enable = true;
      xserver = {
        enable = true;
        displayManager.gdm = {
          enable = true;
          wayland = true;
        };
        desktopManager.gnome.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.open-bar
    ];
  };
}
