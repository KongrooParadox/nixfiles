{
  config,
  domain,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.nextcloud;
in
{
  options.kp.nextcloud = {
    enable = lib.mkEnableOption "Nextcloud instance";

    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "example.org";
      description = lib.mdDoc ''
        FQDN domain of Nextcloud server.
        This will be used as the base url for NGINX reverse proxy.
      '';
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "nextcloud";
      description = lib.mdDoc ''
        Subdomain name for the Nextcloud instance.
        This will be used as the subdomain of NGINX reverse proxy
      '';
    };

    dbType = lib.mkOption {
      type = lib.types.str;
      default = "sqlite";
      description = lib.mdDoc ''
        DB type : one of the following
        sqlite, psql or
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    kp = {
      impermanence = lib.mkIf config.kp.impermanence.enable {
        extraDirectories =
          lib.optionals (!lib.strings.hasPrefix "/mnt/" config.services.nextcloud.datadir)
            [
              config.services.nextcloud.datadir
            ];
      };
      reverseProxy = {
        enable = true;
        domain = cfg.domain;
        services.nextcloud = {
          subdomain = cfg.subdomain;
        };
      };
    };
    sops.secrets."nextcloud" = { };
    services.nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud33;
      hostName = "${cfg.subdomain}.${cfg.domain}";
      config.adminpassFile = config.sops.secrets."nextcloud".path;
      config.dbtype = cfg.dbType;
      https = true;
    };
  };
}
