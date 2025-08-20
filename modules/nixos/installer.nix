{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.package = pkgs.zfs_2_3;
  };
  networking.hostId = "dae522e3";

  kp.home-manager.enable = true;
}
