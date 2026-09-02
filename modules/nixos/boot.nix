{ config, lib, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
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
