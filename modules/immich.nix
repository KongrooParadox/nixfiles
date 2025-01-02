{ config, lib, pkgs, ... }:

let
  cfg = config.immich;
in
{
  options.immich = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
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

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "photos.tavel.kongroo.ovh";
      description = lib.mdDoc ''
        Hostname for the Immich instance.
        This will be used for NGINX virtual host configuration.
      '';
    };

    acme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable ACME SSL certificate management.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "acme@kongroo.anonaddy.com";
        description = lib.mdDoc "Email address for ACME registration and notifications.";
      };

      environmentFile  = lib.mkOption {
        type = lib.types.str;
        default = config.sops.secrets."acme-ovh".path;
        description = lib.mdDoc "Credentials for DNS provider";
      };

      dnsProvider = lib.mkOption {
        type = lib.types.str;
        default = "ovh";
        description = lib.mdDoc "DNS provider for ACME DNS-01 challenge.";
      };

      # OVH-specific options
      useWildcardDomain = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to use wildcard domain for OVH (*.domain.tld).";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = "tavel.kongroo.ovh";
        description = lib.mdDoc "Base domain for the certificate. If useWildcardDomain is true, will use *.domain.";
      };
    };

    nginx = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to configure and enable nginx as a reverse proxy for Immich.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
      };

      users.users.immich = {
        extraGroups = [ "video" "render" ];
        isSystemUser = true;
        group = "immich";
      };
      users.groups.immich = {};

      services.immich = {
        enable = cfg.enable;
        environment = {
          IMMICH_MACHINE_LEARNING_URL = "http://localhost:${toString cfg.machineLearningPort}";
        };
        host = "0.0.0.0";
        mediaLocation = cfg.mediaPath;
        openFirewall = true;
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

      networking.firewall = {
        logRefusedPackets = true;
        allowedTCPPorts = [ 80 443 22 config.services.immich.port ];
        # Internal ports only accessible locally
        interfaces."lo".allowedTCPPorts = [
          config.services.immich.port
          cfg.machineLearningPort
        ];
      };
    }

    (lib.mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        defaultListenAddresses = [ "" ];
        virtualHosts.${cfg.hostname} = {
          enableACME = cfg.acme.enable;
          acmeRoot = null;
          forceSSL = true;
          # Add explicit listen directives
          listen = [
            { addr = "0.0.0.0"; port = 80; }
            { addr = "0.0.0.0"; port = 443; ssl = true; }
          ];
          extraConfig = ''
            # Allow access from all Tailscale IPs
            allow 100.64.0.0/10;  # Tailscale IPv4 range
            allow fe80::/10;      # Tailscale IPv6 range
          '';
          locations."/" = {
            proxyPass = "http://localhost:${toString config.services.immich.port}";
            proxyWebsockets = true;
          };
        };
        appendHttpConfig = ''
          error_log /var/log/nginx/error.log debug;
          access_log /var/log/nginx/access.log combined buffer=512k flush=1m;
        '';
      };
    })

    (lib.mkIf cfg.acme.enable {
      security.acme = {
        acceptTerms = true;
        defaults.email = cfg.acme.email;

        certs.${cfg.hostname} = {
          domain = if cfg.acme.useWildcardDomain
            then "*.${cfg.acme.domain}"
            else cfg.hostname;
          dnsProvider = cfg.acme.dnsProvider;
          environmentFile = cfg.acme.environmentFile;
        };
      };
    })
  ];
}
