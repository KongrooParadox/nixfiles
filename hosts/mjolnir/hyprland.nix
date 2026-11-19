{
  config,
  pkgs,
  ...
}:
let
  home = config.users.users.ops.home;
  dotfiles = "${home}/nixfiles/dotfiles";
  steamosctl = "${pkgs.jovianPackages.steamos-manager}/bin/steamosctl";

  switchToGameMode = pkgs.writeShellScriptBin "switch-to-game-mode" ''
    # Hyprland leaves WAYLAND_DISPLAY=wayland-1 in the systemd user manager.
    # gamescope reads that as "nested mode" and tries to connect to the now-dead
    # socket instead of creating its own, exiting with "Failed to connect to
    # wayland socket". Clear it so the relaunched gamescope session starts clean.
    systemctl --user unset-environment WAYLAND_DISPLAY || true
    # Tell steamos-manager to set the temp SDDM login to gamescope-wayland,
    # then exit Hyprland so SDDM restarts and picks up the new session.
    ${steamosctl} switch-to-game-mode || true
    # Hyprland 0.56 uses a Lua config, so hyprctl dispatch evaluates a Lua
    # expression; quote it so the shell passes hl.dsp.exit() through literally.
    hyprctl dispatch 'hl.dsp.exit()' || true
  '';

  hyprlandLua = pkgs.writeText "hyprland.lua" ''
    local xdg_config_home = "${home}/.config"
    package.path = xdg_config_home .. "/hypr/?.lua;" .. xdg_config_home .. "/hypr/?/init.lua;" .. package.path

    require("config/init")

    -- Mjolnir escape hatch: ALT-based binds that work over Moonlight/Sunshine
    -- (Moonlight does not forward the SUPER key to the host)
    hl.bind("ALT + R", hl.dsp.exec_cmd("${pkgs.rofi}/bin/rofi -show drun"))
    hl.bind("ALT + DELETE", hl.dsp.exec_cmd("${switchToGameMode}/bin/switch-to-game-mode"))
  '';

  rofiConfig = pkgs.writeText "rofi-config.rasi" ''
    configuration {
      modi: "window,drun,ssh,combi";
      show-icons: true;
      font: "hack 10";
      combi-modi: "window,drun,ssh";
    }
    @theme "~/.config/rofi/themes/center.rasi" '';
in
{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    rofi
    kitty
    hyprpicker
    playerctl
  ];

  # Hyprland + rofi config, managed by NixOS without Home Manager.
  systemd.tmpfiles.rules = [
    "d ${home}/.config/hypr - :ops :users - -"
    "L+ ${home}/.config/hypr/hyprland.lua - - - - ${hyprlandLua}"
    "L+ ${home}/.config/hypr/config - - - - ${dotfiles}/hypr/config"
    "d ${home}/.config/rofi - :ops :users - -"
    "d ${home}/.config/rofi/themes - :ops :users - -"
    "L+ ${home}/.config/rofi/config.rasi - - - - ${rofiConfig}"
    "L+ ${home}/.config/rofi/themes/center.rasi - - - - ${dotfiles}/rofi/center.rasi"
  ];
}
