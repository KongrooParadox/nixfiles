{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [
        9191
      ];
      allowedUDPPorts = [ 9191 ];
    };
  };
  kp = {
    home-manager.enable = true;
    impermanence.enable = true;
    media-player = {
      dataDir = "/var/lib/jellyfin";
      enable = true;
    };
    networking.systemd = {
      enable = true;
      nicList = [
        {
          dhcp = "yes";
          name = "eno1";
          prefix = "10";
          requiredForOnline = "yes";
        }
      ];
    };
    podman.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "990";
    };
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "db46c034";
    };
  };
}
