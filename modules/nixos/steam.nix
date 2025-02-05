{ config, lib, ... }:
let
  cfg = config.steam;
in
{
  options.steam = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Activate Steam";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
