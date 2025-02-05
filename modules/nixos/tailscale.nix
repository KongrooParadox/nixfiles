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
      useRoutingFeatures = if cfg.subnetRouter then "server" else "client";
      extraUpFlags = lib.optional cfg.ssh "--ssh" ++
        lib.optional cfg.acceptDns "--accept-dns" ++
        lib.optional cfg.acceptRoutes "--accept-routes" ++
        lib.optional cfg.subnetRouter "--advertise-routes=${lib.concatStringsSep "," cfg.advertisedRoutes}";
    };

    # Configure networking for multi-subnet setup
    networking = {
      firewall = {
        # Allow Tailscale traffic
        trustedInterfaces = [ "tailscale0" ];
        # Allow incoming connections from other subnets via Tailscale
        allowedUDPPorts = [ config.services.tailscale.port ];
        # If this is a subnet router, ensure IP forwarding is enabled
        checkReversePath = lib.mkIf cfg.subnetRouter false;
      };

      # Enable IP forwarding if this is a subnet router
      nat = lib.mkIf cfg.subnetRouter {
        enable = true;
        # Enable IP masquerading for subnet routing
        externalInterface = "tailscale0";
      };
    };

    # Enable IP forwarding at the kernel level
    boot.kernel.sysctl = lib.mkIf cfg.subnetRouter {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Ensure tailscale is started before dependent services
    systemd.services.tailscaled = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
