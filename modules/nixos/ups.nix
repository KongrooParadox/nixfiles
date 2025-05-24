{
  config,
  lib,
  ...
}:
let
  cfg = config.ups;
in
{
  options.ups = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable APC upsd daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
