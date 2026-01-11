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
      wayland = true;
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
            settings."org/gnome/desktop/wm/preferences" = {
              button-layout = ":minimize,maximize,close";
            };
          }
        ];

        environment.systemPackages = with pkgs; [
          gnomeExtensions.dash-to-dock
          gnomeExtensions.open-bar
          gnome-randr
        ];
      }
      {
        services = gnomeCfg;
      }
    ]
  );
}
