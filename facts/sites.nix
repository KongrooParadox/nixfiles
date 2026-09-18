builtins.mapAttrs (site: cfg: cfg) {
  avignon = {
    dns = {
      custom = true;
      resolvers = [ "box" ];
    };
    subnet = "192.168.3.0/24";
    workgroup = "BLANCHISSAGE";
  };
  mrs = {
    dns = {
      custom = true;
      resolvers = [ ];
    };
    subnet = "10.0.1.0/24";
    workgroup = "OCI";
  };
  pernes = {
    dns = {
      custom = true;
      resolvers = [
        "asgard"
        "box"
      ];
    };
    unmanagedHosts = {
      box.ipv4 = "192.168.1.1";
    };
    subnet = "192.168.1.0/24";
    workgroup = "CASA_ANITA";
  };
  tavel = {
    dns = {
      custom = true;
      resolvers = [
        "vili"
        "box"
      ];
    };
    unmanagedHosts = {
      box.ipv4 = "192.168.2.1";
      tasmota-desk.ipv4 = "192.168.2.4";
      tasmota-grill.ipv4 = "192.168.2.2";
      tasmota-laptop.ipv4 = "192.168.2.5";
      tasmota-window.ipv4 = "192.168.2.3";
    };
    subnet = "192.168.2.0/24";
    workgroup = "SKYNET";
  };
}
