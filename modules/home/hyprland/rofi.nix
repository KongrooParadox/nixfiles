{
  config,
  isUnstable,
  lib,
  osConfig,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/nixfiles/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  hyprlandEnable =
    osConfig.kp.desktop.enable == true && osConfig.kp.desktop.environment == "hyprland";
  settingsOption = if isUnstable then "settings" else "extraConfig";
in
{
  config = lib.mkIf hyprlandEnable {
    assertions = [
      {
        assertion = !isUnstable || (lib.versions.majorMinor lib.version) == "26.11";
        message = ''
          Stable is now tracking 26.11 :
            - You can rename the settingsOption for rofi in modules/home/hyprland/rofi.nix to settings
            - Remove let block (needed only for stable == 26.05 compatibility)
        '';
      }
    ];
    stylix.targets.rofi.enable = false;
    programs = {
      rofi = {
        enable = true;
        ${settingsOption} = {
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
