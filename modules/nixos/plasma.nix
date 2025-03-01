{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "plasma")) {
    services = {
      displayManager.sddm.enable = true;
      desktopManager.plasma6.enable = true;
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      oxygen
    ];
  };
}
