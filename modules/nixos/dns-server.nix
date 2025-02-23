{ config, domain, lib, ... }:

let
  cfg = config.dns-server;
in
{
  options.dns-server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable DNS server.";
    };

    publicDomain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "example.com";
      description = lib.mdDoc "Public domain to rewrite";
    };

    localDomain = lib.mkOption {
      type = lib.types.str;
      default = "local";
      description = lib.mdDoc "Local domain (destination of url rewrite)";
    };

    mapping = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Local dns A entries";
    };

    zone = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Local zone file";
    };

  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [ 22 53 5353 ];
        allowedUDPPorts = [ 53 ];
      };
    };
    services = {
      blocky = {
        enable = true;
        settings = {
          upstreams.groups.default = [ "127.0.0.1:5353" ];
          conditional = {
            fallbackUpstream = true;
          };
          customDNS = {
            customTTL = "1h";
            filterUnmappedTypes = true;
            rewrite.${cfg.publicDomain} = cfg.localDomain;
            mapping = cfg.mapping;
            zone = cfg.zone;
          };
          blocking = {
            blackLists = {
              ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
              adult = ["https://blocklistproject.github.io/Lists/porn.txt"];
            };
            clientGroupsBlock.default = [ "ads" "adult" ];
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
            access-control = [ "127.0.0.1/0 allow" ];
            verbosity = 1;
          };
        };
      };
    };
  };
}
