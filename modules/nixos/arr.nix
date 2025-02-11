
{ config, lib, ... }:

let
  cfg = config.arr;
in
{
  options.arr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable the arr suite (Prowlarr, Radarr, Sonarr, Readarr, Lidarr).";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      example = "my-server.example.org";
      description = lib.mdDoc ''
        FQDN Hostname of arr server.
        This will be used as the base url for NGINX reverse proxy.
        '';
    };

    prowlarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Prowlarr.";
      };
    };

    radarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Radarr.";
      };
    };

    readarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Readarr.";
      };
    };

    sonarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Sonarr.";
      };
    };

    lidarr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable lidarr.";
      };
    };

    nzbget = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Nzbget.";
      };
    };

    sabnzbd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable Sabnzbd.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/360592 - Sonar still uses EOL .net 6.0
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];
    users.groups.media = {};

    reverseProxy = {
      hostname = cfg.hostname;
      services = {
        prowlarr.port = 9696;
        sonarr.port = 8989;
        radarr.port = 7878;
        readarr.port = 8787;
        lidarr.port = 8686;
        nzbget.port = 6789;
        # sabnzbd.port = 8080;
      };
    };

    services = {
      prowlarr = {
        enable = cfg.prowlarr.enable;
        openFirewall = true;
      };
      radarr = {
        dataDir = "/mnt/media/radarr/.config/Radarr";
        enable = cfg.radarr.enable;
        group = "media";
        openFirewall = true;
      };
      readarr = {
        dataDir = "/mnt/media/readarr/.config/Readarr";
        enable = cfg.readarr.enable;
        group = "media";
        openFirewall = true;
      };
      sonarr = {
        dataDir = "/mnt/media/sonarr/.config/Sonarr";
        enable = cfg.sonarr.enable;
        group = "media";
        openFirewall = true;
      };
      lidarr = {
        dataDir = "/mnt/media/lidarr/.config/Lidarr";
        enable = cfg.lidarr.enable;
        group = "media";
        openFirewall = true;
      };
      nzbget = lib.mkIf cfg.nzbget.enable {
        enable = true;
        group = "media";
        settings = {
          MainDir = "/mnt/media/downloads";
          "Server1.Name" = "Newshosting";
          "Server1.Host" = "news.newshosting.com";
          "Server1.Port" = "563";
          "Server1.Username" = config.sops.secrets."newshosting/username".path;
          "Server1.Password" = config.sops.secrets."newshosting/password".path;
        };
      };
      sabnzbd = lib.mkIf cfg.sabnzbd.enable {
        enable = cfg.sabnzbd.enable;
        group = "media";
        openFirewall = true;
      };
    };
    sops = lib.mkIf cfg.nzbget.enable {
      secrets."newshosting/username" = {};
      secrets."newshosting/password" = {};
    };
    networking = {
      firewall.allowedTCPPorts = lib.mkIf cfg.nzbget.enable [ 6789 ];
    };
  };
}
