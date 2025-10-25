{
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
    inputs.apple-silicon.nixosModules.default
  ];

  kp = {
    impermanence.enable = true;
    reverseProxy.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "997";
    };
    tailscale.enable = true;
    virtualization.enable = true;
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
    };
  };

  networking = {
    hostId = "a3c9f91c";
    useDHCP = false;
    bridges = {
      "br0" = {
        interfaces = [ "end0" ];
      };
    };
    interfaces."br0".useDHCP = true;
  };

}
