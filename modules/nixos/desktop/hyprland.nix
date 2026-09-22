{
  config,
  lib,
  pkgs,
  users,
  ...
}:
let
  # noctaliaEnable = config.home-manager;
  noctaliaEnable = builtins.any (
    user: config.home-manager.users.${user}.kp.hyprland.bar == "noctalia"
  ) users;
in
{
  config = lib.mkIf (config.kp.desktop.enable && (config.kp.desktop.environment == "hyprland")) {
    environment.sessionVariables.AQ_DRM_DEVICES = lib.mkDefault "/dev/dri/card1";

    kp = {
      impermanence = lib.mkIf config.kp.impermanence.enable {
        extraDirectories = [ "/var/cache/tuigreet" ];
      };
    };

    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
      hyprlock.enable = true;
      thunar.enable = true;
      xfconf.enable = true;
    };

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
    ];
    nix.settings = lib.mkIf noctaliaEnable {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };
}
