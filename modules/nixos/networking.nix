{
  config,
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
    networkmanager.enable = lib.mkEnableOption "networkmanager to manage NICs";
    systemd = {
      enable = lib.mkEnableOption "systemd.network to manage NICs";
      nicList = lib.mkOption {
        default = [ ];
        description = "List of interfaces to configure for our system";
        type = lib.types.listOf nicModule;
      };
    };
  };

  config = {
    networking = {
      firewall = {
        enable = true;
        trustedInterfaces = [
          "wlan0"
          "wlp1s0f0"
          "virbr1"
        ];
      };
      hostName = host;
      networkmanager.enable = cfg.networkmanager.enable;
      useDHCP = false;
      useNetworkd = cfg.systemd.enable;
      wireless.enable = lib.mkForce false;
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
