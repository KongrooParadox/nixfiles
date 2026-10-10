{
  config,
  inputs,
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
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  config = lib.mkIf (config.kp.desktop.enable && (config.kp.desktop.environment == "hyprland")) {
    environment.sessionVariables.AQ_DRM_DEVICES = lib.mkDefault "/dev/dri/card1";

    kp = {
      impermanence = lib.mkIf config.kp.impermanence.enable {
        extraDirectories =
          lib.optionals (!noctaliaEnable) [ "/var/cache/tuigreet" ]
          ++ lib.optionals noctaliaEnable [ "/var/lib/noctalia-greeter/" ];
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
      greetd = lib.mkIf (!noctaliaEnable) {
        enable = true;
        useTextGreeter = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session --asterisks";
          };
        };
      };

      displayManager.noctalia-greeter = lib.mkIf noctaliaEnable {
        enable = true;
        passwordless-sync-users = users;
        settings = {
          cursor = {
            path = pkgs.bibata-cursors;
            size = 24;
            theme = "Bibata-Modern-Ice";
          };
          keyboard.layout = "us";
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
  };
}
