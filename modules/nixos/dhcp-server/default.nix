{
  config,
  gateway,
  helpers,
  host,
  lib,
  nameservers,
  pkgs,
  subnet,
  site,
  ...
}:
let
  cfg = config.kp.dhcp-server;
  interface = helpers.dhcpServerInterfaceOf host;
  range = helpers.dhcpRangeOf site;
  reservationFacts = pkgs.writeText "${site}-dhcp-reservations.json" (
    builtins.toJSON {
      inherit subnet;
      inherit range;
      reservations = helpers.dhcpReservationsOf site;
      staticAddresses = helpers.staticIpv4AddressesOf site;
    }
  );
  reservationOutput = "/run/dnsmasq/${site}-dhcp-reservations.conf";
  reservationSecret = config.sops.secrets."${site}-dhcp-macs".path;
in
{
  options.kp.dhcp-server.enable = lib.mkEnableOption "DHCP server for the host's site";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = host == "vili" && site == "oujda";
        message = "The DHCP server is scoped to vili on the oujda site for now";
      }
    ];

    sops.secrets."${site}-dhcp-macs" = {
      mode = "0400";
      restartUnits = [ "dnsmasq.service" ];
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      settings = {
        port = 0;
        interface = interface;
        bind-interfaces = true;
        dhcp-authoritative = true;
        dhcp-range = [ "${range.start},${range.end},${range.leaseTime}" ];
        dhcp-option = [
          "option:router,${gateway}"
          "option:dns-server,${lib.concatStringsSep "," nameservers}"
        ];
        conf-file = reservationOutput;
      };
    };

    networking.firewall.interfaces.${interface}.allowedUDPPorts = [ 67 ];

    systemd.services.dnsmasq-reservations = {
      description = "Render private dnsmasq DHCP reservations";
      before = [ "dnsmasq.service" ];
      requiredBy = [ "dnsmasq.service" ];
      serviceConfig = {
        Type = "oneshot";
        UMask = "0077";
      };
      script = ''
        ${pkgs.python3}/bin/python3 ${./dhcp-reservations.py} \
          ${lib.escapeShellArg (toString reservationFacts)} \
          ${lib.escapeShellArg (toString reservationSecret)} \
          ${lib.escapeShellArg reservationOutput}
      '';
    };

    systemd.services.dnsmasq = {
      requires = [ "dnsmasq-reservations.service" ];
      after = [ "dnsmasq-reservations.service" ];
    };
  };
}
