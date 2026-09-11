{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.desktop;
  gnomeCfg = {
    displayManager.gdm = {
      enable = true;
    };
    desktopManager.gnome.enable = true;
  };
in
{
  config = lib.mkIf (cfg.enable && (cfg.environment == "gnome")) (
    lib.mkMerge [
      {
        services = {
          xserver.enable = true;
          displayManager.gdm.autoSuspend = false;
          gnome.gnome-browser-connector.enable = true;
        };

        programs.dconf.profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/datetime" = {
                automatic-timezone = true;
              };
              "org/gnome/desktop/wm/preferences" = {
                button-layout = ":minimize,maximize,close";
              };
              "org/gnome/system/location" = {
                enabled = true;
              };
            };
          }
        ];

        environment.systemPackages = with pkgs; [
          gnomeExtensions.dash-to-dock
          gnomeExtensions.open-bar
          gnome-randr
        ];

        time.timeZone = lib.mkForce null; # TZ will be set by desktop user
      }
      {
        services = gnomeCfg;
      }
    ]
  );
}
