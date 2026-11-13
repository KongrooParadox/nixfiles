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
  oujda = {
    dns = {
      custom = true;
      resolvers = [
        "vili"
        "box"
      ];
    };
    dhcp.range = {
      start = "192.168.2.100";
      end = "192.168.2.199";
      leaseTime = "12h";
    };
    unmanagedHosts = {
      box.ipv4 = "192.168.2.1";
      jetkvm = {
        dhcpReservation = true;
        ipv4 = "192.168.2.6";
      };
      tasmota-desk = {
        dhcpReservation = true;
        ipv4 = "192.168.2.4";
      };
      tasmota-grill = {
        dhcpReservation = true;
        ipv4 = "192.168.2.2";
      };
      tasmota-laptop = {
        dhcpReservation = true;
        ipv4 = "192.168.2.5";
      };
      tasmota-window = {
        dhcpReservation = true;
        ipv4 = "192.168.2.3";
      };
    };
    subnet = "192.168.2.0/24";
    workgroup = "SKYNET";
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
        "frigg"
        "box"
      ];
    };
    unmanagedHosts = {
      box.ipv4 = "192.168.3.254";
    };
    subnet = "192.168.3.0/24";
    workgroup = "CARTERESSES";
  };
}
