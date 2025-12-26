{
  config,
  domain,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.virtualization.proxmox;
in
{
  options.kp.virtualization.proxmox = {
    enable = lib.mkEnableOption "Proxmox Virtual Environment (proxmox-nixos project)";

    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "example.org";
      description = lib.mdDoc ''
        FQDN domain of Proxmox server.
        This will be used as the base url for NGINX reverse proxy.
      '';
    };

    ipAddress = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.0";
      description = lib.mdDoc "Ip address of PVE node";
    };
  };

  imports = [ inputs.proxmox-nixos.nixosModules.proxmox-ve ];

  config = lib.mkIf cfg.enable {

    services.proxmox-ve = {
      enable = true;
      ipAddress = cfg.ipAddress;
    };

    nixpkgs.overlays = [
      inputs.proxmox-nixos.overlays.${config.nixpkgs.hostPlatform.system}
    ];

    kp = {
      impermanence = lib.mkIf config.kp.impermanence.enable {
        extraDirectories = [ "/var/lib/pve-cluster" ];
      };
      reverseProxy = {
        enable = true;
        domain = cfg.domain;
        services.proxmox = {
          port = 8006;
          protocol = "https";
        };
      };
    };
  };
}
