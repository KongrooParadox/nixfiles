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
      UPSNAME ups-server
      UPSCABLE usb
      UPSTYPE usb
      #DEVICE
      NETSERVER on
      NISPORT 3551
      NISIP 0.0.0.0
      BATTERYLEVEL 30
      MINUTES 3
    '';
  };
}
