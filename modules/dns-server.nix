{
  # imports = [];
  #
  config = {
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
            rewrite."kongroo.ovh" = "skynet.local";
            mapping = {
              "asgard.skynet.local" = "192.168.1.10";
              "asgard" = "192.168.1.10";
              "tasmota-desk.skynet.local" = "192.168.1.11";
              "tasmota-desk" = "192.168.1.11";
              "tasmota-window.skynet.local" = "192.168.1.12";
              "tasmota-window" = "192.168.1.12";
              "tasmota-nas.skynet.local" = "192.168.1.13";
              "tasmota-nas" = "192.168.1.13";
              "tasmota-tv.skynet.local" = "192.168.1.14";
              "tasmota-tv" = "192.168.1.14";
              "heimdall.skynet.local" = "192.168.1.100";
              "heimdall" = "192.168.1.100";
              "thor.skynet.local" = "192.168.1.101";
              "thor" = "192.168.1.101";
              "kronos.skynet.local" = "192.168.1.102";
              "kronos" = "192.168.1.102";
              "yggdrasil.skynet.local" = "192.168.1.84";
              "yggdrasil" = "192.168.1.84";
            };
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
