{ inputs, ... }:
{
  imports = [
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  powerManagement.cpuFreqGovernor = "powersave";

  virtualization.enable = true;

  networking = {
    useDHCP = false;
    bridges = {
      "br0" = {
        interfaces = [ "end0" ];
      };
    };
    interfaces."br0".useDHCP = true;
  };

  networking.firewall.allowedTCPPorts = [ 3551 ];
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSTYPE usb
      NISIP 0.0.0.0
      BATTERYLEVEL 30
      MINUTES 3
    '';
  };
}
