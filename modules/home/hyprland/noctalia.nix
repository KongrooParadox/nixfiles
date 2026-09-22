{
  config,
  inputs,
  isUnstable,
  lib,
  osConfig,
  ...
}:
let
  noctaliaEnable =
    osConfig.kp.desktop.enable == true
    && osConfig.kp.desktop.environment == "hyprland"
    && config.kp.hyprland.bar == "noctalia";
  noctaliaName = if isUnstable then "noctalia" else "noctalia-shell";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  config = lib.mkIf noctaliaEnable {
    home.file = {
      "Pictures/wallpapers".source = config.lib.file.mkOutOfStoreSymlink "${inputs.big-files}/wallpapers";
    };
    programs.noctalia = {
      enable = true;
      settings = {
        config_version = 14;
        include.files = [ "config/" ];
        storage = {
          key_file = "${config.home.homeDirectory}/.config/noctalia/master_key";
          key_source = "file";
        };
      };
    };

    sops.secrets."noctalia/master_key" = { };

    stylix.targets.${noctaliaName}.enable = false;

    xdg.configFile = {
      "noctalia/config".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles/dotfiles/noctalia";
      "noctalia/master_key".source =
        config.lib.file.mkOutOfStoreSymlink
          config.sops.secrets."noctalia/master_key".path;
    };
  };
}
