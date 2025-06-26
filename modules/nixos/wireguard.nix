{ config, lib, ... }:
{
  options.wireguard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable wireguard tunnels for backup site";
    };
  };

  config = lib.mkIf config.wireguard.enable {
    sops.secrets."wireguard/casa-anita" = { };

    networking.wg-quick.interfaces = {
      wg-casa-anita = {
        autostart = false;
        privateKeyFile = config.sops.secrets."wireguard/casa-anita".path;
        address = [ "192.168.27.65/32" ];
        dns = [ "212.27.38.253" ];
        mtu = 1360;
        peers = [
          {
            publicKey = "aKfJbVgXBM+fJtbxNVmVYImtMwXQAFwlYNh4d6zo6TQ=";
            endpoint = "91.171.231.205:33436";
            allowedIPs = [
              "0.0.0.0/0"
              "192.168.27.64/27"
              "192.168.1.0/24"
              "::/0"
            ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
