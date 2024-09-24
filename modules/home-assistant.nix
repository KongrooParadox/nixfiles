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
          "freebox"
        ];
        config = {
          default_config = {};
          mqtt = {};
        };
      };
    };
    security.sudo.wheelNeedsPassword = false;
    networking = {
      firewall.allowedTCPPorts = [ 1883 8123 22 ];
    };

  };
}
