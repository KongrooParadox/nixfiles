{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.storage;
in
{
  options.storage = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Activate Storage services (SeaweedFS S3 for now)";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [
          808
          888
          8333
          9333
          18080
          18888
          19333
        ];
      };
    };
    environment = {
      systemPackages = [ pkgs.seaweedfs ];
    };
  };
}
