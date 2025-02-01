{ config, pkgs, ... }:
let
  cfg = config.services.seaweedfs;
in
{
  networking = {
    firewall = {
      allowedTCPPorts = [ 808 888 8333 9333 18080 18888 19333 ];
    };
  };
  environment = {
    systemPackages = [ pkgs.seaweedfs ];
  };
}
