{ config, lib, ... }:

let
  cfg = config.tailscale;
in
{
  options.tailscale = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable Tailscale";
    };

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
      default = [];
      example = [ "192.168.1.0/24" ];
      description = lib.mdDoc "Routes to advertise when acting as a subnet router";
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      extraSetFlags = lib.optional config.tailscale.exitNode "--advertise-exit-node";
      enable = true;
      openFirewall = true;
      useRoutingFeatures = if cfg.subnetRouter then "server" else "client";
      extraUpFlags = lib.optional cfg.ssh "--ssh" ++
        lib.optional cfg.acceptDns "--accept-dns" ++
        lib.optional cfg.acceptRoutes "--accept-routes" ++
        lib.optional cfg.subnetRouter "--advertise-routes=${lib.concatStringsSep "," cfg.advertisedRoutes}";
    };
  };
}
