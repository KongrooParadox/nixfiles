{
  config,
  host,
  lib,
  ...
}:
let
  cfg = config.kp.reverseProxy;

  certDir = "/var/lib/tailscale-certs";
  nodeFqdn = "${host}.${cfg.tls.tailnet}";

  # Sub-module for service definitions
  serviceOpts =
    { name, ... }:
    {
      options = {
        port = lib.mkOption {
          type = lib.types.port;
          description = "Local port the service is running at";
        };

        protocol = lib.mkOption {
          type = lib.types.enum [
            "http"
            "https"
          ];
          default = "http";
          description = "Protocol of the service";
        };

        subdomain = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Subdomain for the service (e.g. 'photos' for photos.example.com)";
        };
      };
    };
in
{
  options.kp.reverseProxy = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the reverse proxy service";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain for the reverse proxy";
      example = "example.org";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule serviceOpts);
      default = { };
      description = "A set of services to proxy";
    };

    tls = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "acme"
          "tailscale"
        ];
        default = "acme";
        description = ''
          Where TLS certificates come from. "acme" issues a wildcard
          certificate for the site domain via DNS-01 (OVH). "tailscale" serves
          a single service on the node's ts.net name using a Tailscale-issued
          certificate (requires services.tailscale).
        '';
      };

      tailnet = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Tailnet DNS name (e.g. example.ts.net). Required when tls.mode is
          "tailscale".
        '';
      };
    };

    acme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable ACME SSL certificate management";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "acme@kongroo.anonaddy.com";
        description = "Email address for ACME registration and notifications";
      };

      environmentFile = lib.mkOption {
        type = lib.types.str;
        default = config.sops.secrets."acme-ovh".path;
        description = "Credentials for DNS provider";
      };

      dnsProvider = lib.mkOption {
        type = lib.types.str;
        default = "ovh";
        description = "DNS provider for ACME DNS-01 challenge";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.optionals (cfg.tls.mode == "tailscale") [
      {
        assertion = cfg.tls.tailnet != "";
        message = "kp.reverseProxy.tls.tailnet must be set when tls.mode is \"tailscale\"";
      }
      {
        assertion = builtins.length (builtins.attrValues cfg.services) <= 1;
        message = "kp.reverseProxy.tls.mode = \"tailscale\" serves a single service on the node's ts.net name";
      }
    ];

    sops.secrets."acme-ovh" = lib.mkIf (cfg.tls.mode == "acme") { };

    # Issue or renew the Tailscale HTTPS certificate for the node's ts.net
    # name. tailscaled acts as the ACME client; nginx just consumes the files.
    systemd.services.tailscale-cert = lib.mkIf (cfg.tls.mode == "tailscale") {
      description = "Issue or renew the Tailscale HTTPS certificate for ${nodeFqdn}";
      wants = [
        "network-online.target"
        "tailscaled.service"
      ];
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      before = [ "nginx.service" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "tailscale-certs";
        StateDirectoryMode = "0750";
        ExecStart = ''
          ${lib.getExe config.services.tailscale.package} cert \
            --cert-file ${certDir}/${nodeFqdn}.crt \
            --key-file ${certDir}/${nodeFqdn}.key \
            ${nodeFqdn}
        '';
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      clientMaxBodySize = "0"; # Allow large file uploads

      # Create a virtual host for each service subdomain (or the node's ts.net
      # name when tls.mode is "tailscale")
      virtualHosts = lib.mapAttrs' (
        name: service:
        lib.nameValuePair
          (if cfg.tls.mode == "tailscale" then nodeFqdn else "${service.subdomain}.${cfg.domain}")
          (
            {
              enableACME = false;
              forceSSL = true;
              locations."/" = lib.mkIf (service.subdomain != "nextcloud") {
                proxyPass = "${service.protocol}://localhost:${toString service.port}";
                proxyWebsockets = true;
              };
            }
            // (
              if cfg.tls.mode == "tailscale" then
                {
                  sslCertificate = "${certDir}/${nodeFqdn}.crt";
                  sslCertificateKey = "${certDir}/${nodeFqdn}.key";
                }
              else
                {
                  useACMEHost = cfg.domain;
                }
            )
          )
      ) cfg.services;
    };

    # Ensure nginx user exists and is in the ACME group
    users.users.nginx.extraGroups = lib.mkIf (cfg.tls.mode == "acme") [ "acme" ];

    security.acme = lib.mkIf (cfg.acme.enable && cfg.tls.mode == "acme") {
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

    kp.impermanence =
      lib.mkIf (config.kp.impermanence.enable && cfg.acme.enable && cfg.tls.mode == "acme")
        {
          extraDirectories = [ "/var/lib/acme" ];
        };
  };
}
