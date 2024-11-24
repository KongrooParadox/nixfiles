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
              "tasmota-desk.skynet.local" = "10.10.1.11";
              "tasmota-desk" = "10.10.1.11";
              "tasmota-window.skynet.local" = "10.10.1.12";
              "tasmota-window" = "10.10.1.12";
              "tasmota-nas.skynet.local" = "10.10.1.13";
              "tasmota-nas" = "10.10.1.13";
              "tasmota-tv.skynet.local" = "10.10.1.14";
              "tasmota-tv" = "10.10.1.14";
              "baldur.skynet.local" = "10.10.1.20,10.10.1.21,2a01:cb1d:824f:1000:7f0b:431c:2066:a6ce";
              "baldur" = "10.10.1.20,10.10.1.21,2a01:cb1d:824f:1000:7f0b:431c:2066:a6ce";
              "asgard.skynet.local" = "10.10.1.100,2a01:cb1d:824f:1000:44a0:293a:69fa:1c5f";
              "asgard" = "10.10.1.100,2a01:cb1d:824f:1000:44a0:293a:69fa:1c5f";
              "yggdrasil.skynet.local" = "10.10.1.101,2a01:cb1d:824f:1000:24d1:69f:4b2c:78b9";
              "yggdrasil" = "10.10.1.101,2a01:cb1d:824f:1000:24d1:69f:4b2c:78b9";
              "heimdall.skynet.local" = "10.10.1.102";
              "heimdall" = "10.10.1.102";
              "kronos.skynet.local" = "10.10.1.103";
              "kronos" = "10.10.1.103";
              "thor.skynet.local" = "10.10.1.104";
              "thor" = "10.10.1.104";
              "livebox.skynet.local" = "10.10.1.254";
              "livebox" = "10.10.1.254";
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
