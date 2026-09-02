{
  config,
  pkgs,
  ...
}:
let
  rcloneConfig = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."rclone.conf".path;
in
{
  sops.secrets = {
    "rclone.conf" = { };
  };
  home.packages = with pkgs; [
    rclone
  ];
  xdg.configFile."rclone/rclone.conf".source = rcloneConfig;
}
