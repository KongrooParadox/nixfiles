{
  config,
  domain,
  host,
  lib,
  users,
  ...
}:
let
  cfg = config.kp.networking;
  nicModule = lib.types.submodule {
    options = {
      dhcp = lib.mkOption {
        default = "yes";
        description = ''
          Set to yes only if the following statement applies :
          Should my interface be given a DHCP lease ?
        '';
        type = lib.types.enum [
          "yes"
          "no"
        ];
      };
      prefix = lib.mkOption {
        description = ''
          Prefix of NIC name for network definition
          E.g 10-eth0 with prefix = 10
        '';
        type = lib.types.str;
        example = "10";
      };
      name = lib.mkOption {
        description = "Network Interface Controller name";
        type = lib.types.str;
        example = "eth0";
      };
      requiredForOnline = lib.mkOption {
        default = "no";
        description = ''
          Set to yes only if the following statement applies :
          Is this interface critical for the system to be considered online ?
        '';
        type = lib.types.enum [
          "yes"
          "no"
        ];
      };
    };
  };
in
{
  options.kp.networking = {
    networkmanager = {
      enable = lib.mkEnableOption "networkmanager to manage NICs";
      useDHCP = lib.mkOption {
        default = true;
        description = "DHCP for network Manager";
      };
      wireless = lib.mkEnableOption "Wireless";
    };
    systemd = {
      enable = lib.mkEnableOption "systemd.network to manage NICs";
      nicList = lib.mkOption {
        default = [ ];
        description = "List of interfaces to configure for our system";
        type = lib.types.listOf nicModule;
      };
      resolved = lib.mkOption {
        default = true;
        description = "systemd-resolved for DNS";
      };
    };
    fallbackNameservers = lib.mkOption {
      default = [
        "9.9.9.9"
      ];
      description = "List of fallback dns servers for systems";
      type = lib.types.listOf lib.types.str;
    };
    nameservers = lib.mkOption {
      default =
        [ ]
        ++ lib.optionals (domain == "tavel.kongroo.ovh") [
          "192.168.2.103"
          "192.168.2.254"
        ]
        ++ lib.optionals (domain == "pernes.kongroo.ovh") [
          "192.168.1.100"
          "192.168.1.254"
        ];
      description = "List of default dns servers for systems";
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    networking = {
      firewall = {
        enable = true;
        trustedInterfaces = [
          "wlan0"
          "wld0"
          "wlp1s0f0"
          "virbr1"
        ];
      };
      hostName = host;
      nameservers = cfg.nameservers;
      networkmanager.enable = lib.mkDefault cfg.networkmanager.enable;
      useDHCP = lib.mkForce cfg.networkmanager.useDHCP;
      useNetworkd = cfg.systemd.enable;
      wireless.enable = lib.mkForce cfg.networkmanager.wireless;
    };

    systemd.network = lib.mkIf cfg.systemd.enable {
      enable = true;
      networks = builtins.listToAttrs (
        map (nic: {
          name = "${nic.prefix}-${nic.name}";
          value = {
            matchConfig.Name = nic.name;
            networkConfig.DHCP = nic.dhcp;
            linkConfig.RequiredForOnline = nic.requiredForOnline;
          };
        }) cfg.systemd.nicList
      );
    };

    services.resolved = lib.mkIf cfg.systemd.enable {
      enable = lib.mkForce cfg.systemd.resolved;
      settings.Resolve = {
        DNSSEC = "false";
        # Domains = [ "~." ];
        DNSOverTLS = "false";
        FallbackDNS = cfg.fallbackNameservers;
      };
    };
    users.users = lib.mkIf cfg.networkmanager.enable (
      builtins.listToAttrs (
        map (user: {
          name = user;
          value.extraGroups = [ "networkmanager" ];
        }) users
      )
    );
  };
}
