{
  config,
  domain,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.immich;
in
{
  options.immich = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable Immich instance.";
    };

    machineLearningPort = lib.mkOption {
      type = lib.types.port;
      default = 3003;
      description = lib.mdDoc ''
        Port for machine learning service.
        Must be accessible from the main Immich service.
      '';
    };

    mediaPath = lib.mkOption {
      type = lib.types.path;
      default = "/mnt/media/immich";
      description = lib.mdDoc ''
        Path to media library root directory.
        This directory must exist and be writable by the immich user.
      '';
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "example.org";
      description = lib.mdDoc ''
        FQDN domain of Immich server.
        This will be used as the base url for NGINX reverse proxy.
      '';
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "gallery";
      description = lib.mdDoc ''
        Subdomain name for the Immich instance.
        This will be used as the subdomain of NGINX reverse proxy
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    users.users.immich = {
      extraGroups = [
        "video"
        "render"
      ];
      isSystemUser = true;
      group = lib.mkForce "media";
    };
    users.groups.media = { };

    services.immich = {
      enable = cfg.enable;
      environment = {
        IMMICH_MACHINE_LEARNING_URL = "http://localhost:${toString cfg.machineLearningPort}";
      };
      host = "0.0.0.0";
      mediaLocation = cfg.mediaPath;
      openFirewall = true;
    };

    networking.firewall.allowedTCPPorts = [ cfg.machineLearningPort ];

    # Configure reverse proxy for Immich web interface
    reverseProxy = {
      domain = cfg.domain;
      services.immich = {
        port = config.services.immich.port;
        subdomain = cfg.subdomain;
      };
    };

    systemd.services.immich-media-dir = {
      description = "Create Immich media directory";
      wantedBy = [ "multi-user.target" ];
      before = [ "immich.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/mkdir -p ${cfg.mediaPath}";
        ExecStartPost = "${pkgs.coreutils}/bin/chown -R ${config.services.immich.user}:${config.services.immich.group} ${cfg.mediaPath}";
      };
    };
  };
}
