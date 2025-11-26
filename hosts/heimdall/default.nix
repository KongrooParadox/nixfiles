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
    arr = {
      enable = true;
      mediaBasePath = "/mnt/share/media";
      computeBasePath = "/var/lib/compute";
    };
    impermanence.enable = true;
    samba.client = {
      enable = true;
      uid = "1000";
      gid = "997";
    };
    ups.enable = true;
    virtualization = {
      enable = true;
      bridgeInterfaceName = "end0";
      libvirtd.enable = true;
    };
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
      hostId = "a3c9f91c";
    };
  };
}
