{ config, lib, ...}:
let
  cfg = config.home-assistant;
in
{
  options.home-assistant = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable HA instance.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      example = "my-server.example.org";
      description = lib.mdDoc ''
        Hostname for the HA instance.
        This will be used as the base url for NGINX reverse proxy.
      '';
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "home-assistant";
      description = lib.mdDoc ''
        Subdomain name for the HA instance.
        This will be used as the subdomain of NGINX reverse proxy
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    reverseProxy = {
      hostname = cfg.hostname;
      services.home-assistant = {
        port = 8123;
        subdomain = cfg.subdomain;
      };
    };
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
    };
    networking = {
      firewall.allowedTCPPorts = [ 1883 ];
    };
  };
}
