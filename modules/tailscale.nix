{ config, lib, ... }:{
  options = {
    tailscale = {
      enable = lib.mkEnableOption "Enable Tailscale VPN service";

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
        default = [ "10.10.111.0/24" ];
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
        ["--accept-routes"] ++
        (lib.optional config.tailscale.subnetRouter "--advertise-routes=${builtins.concatStringsSep","config.tailscale.advertisedRoutes}");
      openFirewall = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "both";
    };
  };
}
