{ config, pkgs, ... }:
{
  sops.secrets = {
    "rclone.conf" = {};
  };
  home.packages = with pkgs; [
    chromium
    rclone
  ];
  # xdg.configFile."rclone/rclone.conf".source = config.sops.secrets."rclone.conf".path;
}
