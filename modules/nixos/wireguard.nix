{ config, lib, ... }:
{
  options.kp.wireguard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable wireguard tunnels for backup sites";
    };
  };

  config = lib.mkIf config.kp.wireguard.enable {
    sops.secrets = {
      "wireguard/blanchissage" = { };
      "wireguard/casa-anita" = { };
    };

    networking.wg-quick.interfaces = {
      wg-blanchissage = {
        autostart = false;
        privateKeyFile = config.sops.secrets."wireguard/blanchissage".path;
        address = [ "192.168.27.65/32" ];
        dns = [ "212.27.38.253" ];
        mtu = 1360;
        peers = [
          {
            publicKey = "O/192m1j+OyVTQn05IY2n2s2fhs8CBmZi6VqDWkr7mg=";
            endpoint = "91.162.26.75:53080";
            allowedIPs = [
              "0.0.0.0/0"
              "192.168.27.64/27"
              "192.168.3.0/24"
              "::/0"
            ];
            persistentKeepalive = 25;
          }
        ];
      };
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
