{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.podman;
in
{
  options.kp.podman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Enable podman containers and related tooling";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = with pkgs; [
      buildah
      distrobox
      dive
      podman-compose
      podman-tui
    ];
  };
}
