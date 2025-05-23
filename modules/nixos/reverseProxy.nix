{
  config,
  host,
  lib,
  ...
}:
let
  cfg = config.reverseProxy;

  # Sub-module for service definitions
  serviceOpts =
    { name, ... }:
    {
      options = {
        port = lib.mkOption {
          type = lib.types.port;
          description = lib.mdDoc "Local port the service is running on";
        };

        subdomain = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = lib.mdDoc "Subdomain for the service (e.g. 'photos' for photos.example.com)";
        };
      };
    };
in
{
  options.reverseProxy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable the reverse proxy service";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = lib.mdDoc "Base domain for the reverse proxy";
      example = "example.org";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule serviceOpts);
      default = { };
      description = lib.mdDoc "Attribute set of services to proxy";
    };

    acme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable ACME SSL certificate management";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "acme@kongroo.anonaddy.com";
        description = lib.mdDoc "Email address for ACME registration and notifications";
      };

      environmentFile = lib.mkOption {
        type = lib.types.str;
        default = config.sops.secrets."acme-ovh".path;
        description = lib.mdDoc "Credentials for DNS provider";
      };

      dnsProvider = lib.mkOption {
        type = lib.types.str;
        default = "ovh";
        description = lib.mdDoc "DNS provider for ACME DNS-01 challenge";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      clientMaxBodySize = "0"; # Allow large file uploads

      # Create virtual host for each service subdomain
      virtualHosts = lib.mapAttrs' (
        name: service:
        lib.nameValuePair "${service.subdomain}.${cfg.domain}" {
          enableACME = false; # Disable per-host ACME
          useACMEHost = cfg.domain; # Use the wildcard cert
          forceSSL = true;

          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString service.port}";
            proxyWebsockets = true;
          };
        }
      ) cfg.services;
    };

    # Ensure nginx user exists and is in the ACME group
    users.users.nginx.extraGroups = [ "acme" ];

    security.acme = lib.mkIf cfg.acme.enable {
      acceptTerms = true;
      defaults = {
        email = cfg.acme.email;
        dnsProvider = cfg.acme.dnsProvider;
        environmentFile = cfg.acme.environmentFile;
        dnsPropagationCheck = true;
        dnsResolver = "9.9.9.9:53";
        group = "nginx";
      };

      # Single wildcard cert for all subdomains
      certs.${cfg.domain} = {
        domain = "*.${cfg.domain}";
        extraDomainNames = [ "*.${host}.${cfg.domain}" ];
        dnsProvider = cfg.acme.dnsProvider;
        environmentFile = cfg.acme.environmentFile;
        group = "nginx";
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
