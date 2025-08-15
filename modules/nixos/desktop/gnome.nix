{
  config,
  lib,
  pkgs,
  ...
}:
let
  isUnstable = lib.versions.majorMinor lib.version == "25.11";
  gnomeCfg = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };
in
{
  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "gnome")) (
    lib.mkMerge [
      {
        services = {
          xserver.enable = true;
          gnome.gnome-browser-connector.enable = true;
        };

        environment.systemPackages = with pkgs; [
          gnomeExtensions.dash-to-dock
          gnomeExtensions.open-bar
        ];
      }
      (
        if isUnstable then
          {
            services = gnomeCfg;
          }
        else
          {
            services.xserver = gnomeCfg;
          }
      )
    ]
  );
}
