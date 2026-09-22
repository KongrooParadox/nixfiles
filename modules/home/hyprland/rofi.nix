{
  config,
  lib,
  osConfig,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/nixfiles/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  hyprlandEnable =
    osConfig.kp.desktop.enable == true && osConfig.kp.desktop.environment == "hyprland";
in
{
  config = lib.mkIf hyprlandEnable {
    stylix.targets.rofi.enable = false;
    programs = {
      rofi = {
        enable = true;
        extraConfig = {
          modi = "window,drun,ssh,combi";
          show-icons = true;
          font = "hack 10";
          combi-modi = "window,drun,ssh";
        };
        theme = "~/.config/rofi/themes/center.rasi";

      };
    };
    xdg.configFile."rofi/themes" = {
      source = mkSymlink "${dotfiles}/rofi";
    };
  };
}
