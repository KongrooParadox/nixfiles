{ inputs, ... }:
{
  imports = [
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  desktop.enable = true;
  virtualization.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  samba.client.enable = true;
}
