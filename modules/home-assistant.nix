{ config, ...}:

{
  imports = [];

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
        enable = true;
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
        enable = true;
        recommendedProxySettings = true;
        virtualHosts."asgard.kongroo.ovh" = {
          enableACME = true;
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
      certs."asgard.kongroo.ovh" = {
        domain = "*.kongroo.ovh";
        dnsProvider = "ovh";
        environmentFile = config.sops.secrets."acme-ovh".path;
      };
      defaults = {
        email = "acme@kongroo.anonaddy.com";
      };
    };
    security.sudo.wheelNeedsPassword = false;
    networking = {
      firewall.allowedTCPPorts = [ 443 1883 22 ];
    };

  };
}
