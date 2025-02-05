{ config, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    };
    extraModulePackages = with config.boot.kernelPackages; [
      evdi
    ];
    supportedFilesystems = [ "ntfs" ];
  };
}
