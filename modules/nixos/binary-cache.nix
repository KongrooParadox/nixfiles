{
  config,
  lib,
  ...
}:
let
  cfg = config.binary-cache;
in
{
  options.binary-cache = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Activate attic binary cache demon.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.atticd = {
      enable = true;
      environmentFile = config.sops.secrets."attic/server-token".path;
    };
    sops.secrets."attic/server-token" = { };
    networking.firewall.allowedTCPPorts = [ 8080 ];
  };
}
