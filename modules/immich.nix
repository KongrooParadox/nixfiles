{ config, ...}:

{
  config = {
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
    users.users.immich.extraGroups = [ "video" "render"];
    services = {
      immich = {
        enable = true;
        environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
        host = "0.0.0.0";
        mediaLocation = "/mnt/media/immich";
        openFirewall = true;
        # settings.server.externalDomain = "kongroo.ovh";
      };
      nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."yggdrasil.kongroo.ovh" = {
          enableACME = true;
          acmeRoot = null;
          forceSSL = true;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://yggdrasil.kongroo.ovh:2283";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      certs."yggdrasil.kongroo.ovh" = {
        domain = "*.kongroo.ovh";
        dnsProvider = "ovh";
        environmentFile = config.sops.secrets."acme-ovh".path;
      };
      defaults = {
        email = "acme@kongroo.anonaddy.com";
      };
    };

    networking = {
      firewall.allowedTCPPorts = [ 443 22 ];
    };
  };
}
