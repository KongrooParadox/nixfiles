{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  kp = {
    impermanence.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
    };
  };

  networking = {
    hostId = "02ce4009";
    # useDHCP = false;
    # bridges = {
    #   "br0" = {
    #     interfaces = [ "eno0" ];
    #   };
    # };
    # interfaces."br0".useDHCP = true;
  };

}
