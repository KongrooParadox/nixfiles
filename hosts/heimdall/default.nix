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
    tailscale = {
      advertisedRoutes = [ "192.168.2.0/24" ];
      exitNode = false;
      subnetRouter = true;
    };
    ups.enable = true;
    virtualization = {
      enable = true;
      libvirtd.enable = true;
    };
    zfs = {
      enable = true;
      encryptionKeys = [ "encrypted.key" ];
    };
  };

  networking = {
    hostId = "a3c9f91c";
  };

}
