{ inputs, ... }:
{
  imports = [
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";

  desktop.enable = true;
  virtualization.enable = true;
}
