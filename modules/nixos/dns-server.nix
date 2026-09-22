{
  config,
  domain,
  lib,
  zone,
  ...
}:
let
  cfg = config.kp.dns-server;
in
{
  options.kp.dns-server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable DNS server.";
    };

    zone = lib.mkOption {
      type = lib.types.str;
      default = zone;
      description = ''
        Split-horizon zone served on the LAN, derived from `facts/machines.nix` & `facts/sites.nix`.
        Its `$ORIGIN` is the site's public domain.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [
          22
          53
          5353
        ];
        allowedUDPPorts = [ 53 ];
      };
    };
    services = {
      blocky = {
        enable = true;
        settings = {
          upstreams.groups.default = [ "127.0.0.1:5353" ];
          customDNS = {
            filterUnmappedTypes = true;
            zone = cfg.zone;
          };
          blocking = {
            denylists = {
              ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
              adult = [ "https://blocklistproject.github.io/Lists/porn.txt" ];
            };
            clientGroupsBlock.default = [
              "ads"
              "adult"
            ];
          };
          ports.dns = 53;
        };
      };
      unbound = {
        enable = true;
        resolveLocalQueries = false;
        settings = {
          server = {
            interface = "127.0.0.1@5353";
            verbosity = 1;
          };
        };
      };
      resolved.enable = false;
    };

    systemd.services.blocky = {
      after = [ "unbound.service" ];
      wants = [ "unbound.service" ];
    };
  };
}
