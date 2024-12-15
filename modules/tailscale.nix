{ config, lib, ... }:{
  options = {
    tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale VPN service";

      acceptRoutes = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this node should accept DNS routes from the tailnet";
      };

      exitNode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this node should advertise itself as an exit node";
      };

      ssh = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Tailscale SSH server";
      };

      subnetRouter = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this node should act as a subnet router";
      };

      advertisedRoutes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of subnets to advertise when acting as a subnet router";
      };
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      authKeyFile = lib.mkDefault config.sops.secrets."tailscale/server-key".path;
      enable = lib.mkDefault true;
      extraSetFlags = lib.optional config.tailscale.exitNode "--advertise-exit-node";
      extraUpFlags =
        (lib.optional config.tailscale.ssh "--ssh") ++
        (lib.optional config.tailscale.acceptRoutes "--accept-routes") ++
        (lib.optional config.tailscale.subnetRouter "--advertise-routes=${builtins.concatStringsSep","config.tailscale.advertisedRoutes}");
      openFirewall = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "both";
    };
  };
}
