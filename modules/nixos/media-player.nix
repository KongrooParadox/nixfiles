{
  config,
  domain,
  lib,
  users,
  ...
}:
let
  cfg = config.kp.media-player;
  user = lib.lists.head users;
in
{
  options.kp.media-player = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable the media suite (Jellyfin & co).";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/compute/jellyfin";
      description = lib.mdDoc "Path to jellyfin persistent storage";
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
    users = {
      users.${user}.extraGroups = [ "media" ];
      groups.media = { };
    };

    kp.reverseProxy = {
      enable = true;
      domain = cfg.domain;
      services = {
        jellyfin.port = 8096;
      };
    };

    networking.firewall = {
      allowedUDPPortRanges = [
        {
          from = 40000;
          to = 40010;
        }
      ];
      allowedTCPPortRanges = [
        {
          from = 40000;
          to = 40010;
        }
      ];
    };

    kp.impermanence = lib.mkIf config.kp.impermanence.enable {
      extraDirectories = lib.optionals (!lib.strings.hasPrefix "/mnt/share" cfg.dataDir) [ cfg.dataDir ];
    };

    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
      dataDir = cfg.dataDir;
    };
  };
}
