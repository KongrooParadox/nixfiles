{
  config,
  lib,
  usesDisplaylink,
  ...
}:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    extraModulePackages = lib.mkIf usesDisplaylink (with config.boot.kernelPackages; [ evdi ]);
    supportedFilesystems = [ "ntfs" ];
  };
}
