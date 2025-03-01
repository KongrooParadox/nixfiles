{ config, lib, pkgs, ... }:
let
  cfg = config.podman;
in
{
  options.podman = {
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
      dive
      podman-tui
      # docker-compose
      podman-compose
    ];
  };
}
