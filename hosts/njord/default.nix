{ inputs, lib, ... }:
{
  imports = [
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  powerManagement = {
    enable = true;
    powertop.enable = lib.mkForce false;
    cpuFreqGovernor = "performance";
  };

  desktop.enable = true;
  virtualization.enable = true;
}
