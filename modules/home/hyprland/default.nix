{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.kp.hyprland;
  hyprlandEnable =
    osConfig.kp.desktop.enable == true && osConfig.kp.desktop.environment == "hyprland";
  barLauncher =
    if cfg.bar == "noctalia" then
      "${pkgs.killall}/bin/killall -q noctalia;sleep 1 && noctalia &"
    else
      # quickshell
      "${pkgs.killall}/bin/killall -q qs;sleep 1 && qs &";
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${barLauncher}
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
      ];
      default = "noctalia";
      description = "bar implementation for hyprland";
    };
  };

  imports = [
    ./noctalia.nix
    ./rofi.nix
    ./wlogout.nix
  ];

  config = lib.mkIf hyprlandEnable {
    home.packages =
      with pkgs;
      [
        (import ../../../scripts/launcher.nix { inherit config pkgs; })
        (import ../../../scripts/clipboard-history.nix { inherit config pkgs; })
        (import ../../../scripts/screen-capture.nix { inherit config pkgs; })
        (import ../../../scripts/lock-screen.nix { inherit config pkgs; })
        (import ../../../scripts/list-hypr-bindings.nix { inherit pkgs; })
      ]
      ++ lib.optionals (builtins.elem cfg.bar [
        "quickshell"
      ]) [ quickshell ]
      ++ lib.optionals (cfg.bar != "noctalia") [
        cliphist
        wl-clipboard
      ];

    stylix.targets.hyprland.enable = false;

    xdg.configFile = {
      "hypr/config".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles/dotfiles/hypr/config";
    };

    wayland.windowManager.hyprland = {
      configType = "lua";
      extraConfig = ''require("config/init")'';
      enable = true;
      # We use the Hyprland packages from the NixOS module
      package = null;
      portalPackage = null;
      settings.on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("${startupScript}/bin/start")
            end
          '')
        ];
      };
      # conflicts with UWSM
      systemd.enable = false;
    };
  };
}
