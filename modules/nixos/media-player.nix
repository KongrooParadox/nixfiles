{ config, domain, lib, ... }:
let
  cfg = config.media-player;
in
{
  options.media-player = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable the media suite (Jellyfin & co).";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "example.org";
      description = lib.mdDoc ''
        FQDN domain of Jellyfin server.
        This will be used as the base url for NGINX reverse proxy.
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.media = {};

    reverseProxy = {
      domain = cfg.domain;
      services = {
        jellyfin.port = 8096;
      };
    };

    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
      dataDir = "/mnt/compute/jellyfin";
    };
  };
}
