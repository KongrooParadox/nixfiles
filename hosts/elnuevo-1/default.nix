{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  kp = {
    impermanence.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    virtualization = {
      bridgeInterfaceName = "eno1";
      enable = true;
      proxmox = {
        enable = true;
        ipAddress = "192.168.2.99";
      };
    };
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "02ce4009";
    };
  };

}
