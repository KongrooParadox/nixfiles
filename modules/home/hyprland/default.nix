{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.hyprland;
  barLauncher =
    if cfg.bar == "waybar" then
      "${pkgs.killall}/bin/killall -q waybar;sleep 1 && waybar-launcher &"
    else if cfg.bar == "noctalia" then
      "${pkgs.killall}/bin/killall -q noctalia-shell;sleep 1 && noctalia-shell &"
    else
      "${pkgs.killall}/bin/killall -q qs;sleep 1 && qs &";
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.killall}/bin/killall -q swww;sleep 1 && ${pkgs.swww}/bin/swww-daemon &
    ${barLauncher}
    ${pkgs.killall}/bin/killall -q swaync &
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &
    ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policylit-agent &
    ${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store &
  '';
in
{
  options.kp.hyprland = {
    bar = lib.mkOption {
      type = lib.types.enum [
        "noctalia"
        "quickshell"
        "waybar"
      ];
      default = "noctalia";
      description = lib.mdDoc "bar implementation for hyprland";
    };
  };
  imports = [
    ./noctalia.nix
    ./rofi.nix
    ./swaync.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  config = {
    home.packages =
      with pkgs;
      [
        cliphist
        wl-clipboard
        (import ../../../scripts/rofi-launcher.nix { inherit pkgs; })
        (import ../../../scripts/rofi-clipboard-history.nix { inherit pkgs; })
        (import ../../../scripts/screen-capture.nix { inherit pkgs; })
        (import ../../../scripts/list-hypr-bindings.nix { inherit pkgs; })
      ]
      ++ lib.optionals (builtins.elem cfg.bar [
        "noctalia"
        "quickshell"
      ]) [ quickshell ];

    stylix.targets.hyprland.enable = false;
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          ipc = "off";
          splash = false;
          preload = [
            "${../../../wallpapers/ghibli-landscape.png}"
            "${../../../wallpapers/vestrahorn-mountain.jpg}"
            "${../../../wallpapers/water-dragon.png}"
          ];
          wallpaper = [
            "eDP-1,${../../../wallpapers/water-dragon.png}"
            "DVI-I-1,${../../../wallpapers/ghibli-landscape.png}"
            "DVI-I-2,${../../../wallpapers/vestrahorn-mountain.jpg}"
          ];
        };
      };
    };

    xdg.configFile = {
      "hypr/extraConfig.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles/dotfiles/hypr/extraConfig.conf";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      settings = {
        exec-once = ''${startupScript}/bin/start'';
      };
      extraConfig = "source = ~/.config/hypr/extraConfig.conf";
    };
  };
}
