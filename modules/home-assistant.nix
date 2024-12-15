{ config, lib, ...}:

let
  cfg = config.home-assistant;
in
{
  options.home-assistant = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable HA instance.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "asgard.tavel.kongroo.ovh";
      description = lib.mdDoc ''
        Hostname for the HA instance.
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
          Whether to configure and enable nginx as a reverse proxy for HA.
        '';
      };
    };
  };

  config = {
    services = {
      mosquitto = {
        enable = true;
        listeners = [
        {
          users.mosquitto = {
            acl = [
              "readwrite #"
            ];
            hashedPassword = "$7$101$zZowRHVB/HcjcgnJ$q4L1Vgw+riu3UBpBpjSPzS6P0hOrodx/bf1lWqEH5TR0aqYz2sl71eG04ksY/II98rGi1kFHndS9O3KsNLrbtw==";
          };
        }
        ];
      };
      home-assistant = {
        enable = cfg.enable;
        extraComponents = [
          "esphome"
          "met"
          "radio_browser"
          "mqtt"
          "tasmota"
          "google_translate"
        ];
        config = {
          default_config = {};
          http = {
            server_host = "::1";
            trusted_proxies = [ "::1" ];
            use_x_forwarded_for = true;
          };
          mqtt = {};
        };
      };
      nginx = {
        enable = cfg.nginx.enable;
        recommendedProxySettings = true;
        virtualHosts.${cfg.hostname} = {
          enableACME = cfg.acme.enable;
          acmeRoot = null;
          forceSSL = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
          };
        };
      };
    };
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
    security.sudo.wheelNeedsPassword = false;
    networking = {
      firewall.allowedTCPPorts = [ 443 1883 22 ];
    };

  };
}
