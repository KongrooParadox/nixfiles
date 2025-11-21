{
  config,
  domain,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.tailscale;
  keyName =
    if (domain == "tavel.kongroo.ovh") then "tailscale/keys/tavel" else "tailscale/keys/pernes";
in
{
  options.kp.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable Tailscale";
    };

    autoconnect = lib.mkEnableOption "enables autoconnect via authKey";

    ssh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable Tailscale SSH";
    };

    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this node should advertise itself as an exit node";
    };

    subnetRouter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether this node acts as a subnet router";
    };

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to accept DNS config from tailscale";
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to accept routes from other subnet routers";
    };

    advertisedRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "192.168.1.0/24" ];
      description = lib.mdDoc "Routes to advertise when acting as a subnet router";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mkIf cfg.autoconnect {
      "${keyName}" = { };
    };

    networking = lib.mkIf cfg.subnetRouter {
      firewall = {
        allowedUDPPortRanges = [
          {
            from = 40000;
            to = 40010;
          }
        ];
        allowedTCPPortRanges = [
          {
            from = 40000;
            to = 40010;
          }
        ];
      };
    };

    systemd.services = lib.mkIf cfg.exitNode or cfg.subnetRouter {
      ethtool-tailscale = {
        description = "ethtool optimizations for tailscale performance";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = ''
            NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
            ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
        wantedBy = [ "network-pre.target" ];
      };
    };

    services.tailscale = {
      authKeyFile = if cfg.autoconnect then config.sops.secrets."${keyName}".path else null;
      enable = true;
      extraUpFlags =
        lib.optional cfg.ssh "--ssh"
        ++ lib.optional cfg.acceptDns "--accept-dns"
        ++ lib.optional cfg.acceptRoutes "--accept-routes"
        ++ lib.optional cfg.subnetRouter "--advertise-routes=${lib.concatStringsSep "," cfg.advertisedRoutes}";
      extraSetFlags = lib.optional cfg.exitNode "--advertise-exit-node";
      openFirewall = true;
      useRoutingFeatures = if cfg.subnetRouter then "server" else "client";
    };
  };
}
