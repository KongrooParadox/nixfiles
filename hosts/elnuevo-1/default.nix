{ ipv4, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  kp = {
    impermanence.enable = true;
    nextcloud.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    virtualization = {
      bridgeInterfaceName = "eno1";
      enable = true;
      proxmox = {
        enable = false;
        ipAddress = ipv4;
      };
    };
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "02ce4009";
    };
  };

}
