{ config, lib, ... }:{
  options = {
    tailscale =
    {
      enable =
        lib.mkEnableOption "enables tailscale module";
      ssh = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      subnetRouter = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      authKeyFile = lib.mkDefault config.sops.secrets."tailscale/server-key".path;
      enable = lib.mkDefault true;
      extraUpFlags =
        (lib.optional config.tailscale.ssh "--ssh") ++
        (lib.optional config.tailscale.subnetRouter "--advertise-routes=10.10.1.0/24");
      #
      # extraUpFlags = [
      #   "--ssh"
      #   # "--advertise-routes=10.10.1.100/24"
      # ];
      openFirewall = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "both";
    };
  };
}

