{ config, domain, lib, ... }:

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

    deluge = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable Deluge torrent download client.";
      };

      wireguardInterface = lib.mkOption {
        type = lib.types.str;
        default = "wg-p2p";
        description = lib.mdDoc "Name of Wireguard interface to use for deluge traffic";
      };
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = domain;
      example = "my-server.example.org";
      description = lib.mdDoc ''
        FQDN domain of arr server.
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
    sops.secrets = lib.mkMerge [
      (lib.mkIf cfg.nzbget.enable {
        "newshosting/username" = {};
        "newshosting/password" = {};
       })
      (lib.mkIf cfg.deluge.enable {
        "deluge-auth" = {
            mode = "0440";
            group = "media";
          };
        "wireguard/proton/p2p" = {};
      })
    ];

    # https://github.com/NixOS/nixpkgs/issues/360592 - Sonar still uses EOL .net 6.0
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];
    users.groups.media = {};

    reverseProxy = {
      domain = cfg.domain;
      services = {
        deluge.port = 8112;
        lidarr.port = 8686;
        nzbget.port = 6789;
        prowlarr.port = 9696;
        radarr.port = 7878;
        readarr.port = 8787;
        # sabnzbd.port = 8080;
        sonarr.port = 8989;
      };
    };

    services = {
      deluge = lib.mkIf cfg.deluge.enable {
        authFile = config.sops.secrets."deluge-auth".path;
        config = {
          allow_remote = false;
          download_location = "/mnt/media/downloads/torrents/current";
          max_half_open_connections = 100;
          max_connections_per_second = 100;
          move_completed = true;
          move_completed_path = "/mnt/media/downloads/torrents/completed";
          outgoing_interface = cfg.deluge.wireguardInterface;
          pre_allocate_storage = false; # ZFS doesn't support fallocate
          torrentfiles_location = "/mnt/media/downloads/torrents/files";
          enabled_plugins = [ "Label" ];
        };
        dataDir = "/mnt/compute/deluge/";
        declarative = true;
        enable = true;
        group = "media";
        openFilesLimit = 2000;
        openFirewall = true;
        web = {
          enable = true;
          openFirewall = true;
        };
      };

      prowlarr = lib.mkIf cfg.prowlarr.enable {
        enable = true;
        openFirewall = true;
      };

      radarr = lib.mkIf cfg.radarr.enable {
        dataDir = "/mnt/compute/radarr/.config/Radarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      readarr = lib.mkIf cfg.readarr.enable {
        dataDir = "/mnt/compute/readarr/.config/Readarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      sonarr = lib.mkIf cfg.sonarr.enable {
        dataDir = "/mnt/compute/sonarr/.config/Sonarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      lidarr = lib.mkIf cfg.lidarr.enable {
        dataDir = "/mnt/compute/lidarr/.config/Lidarr";
        enable = true;
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
        enable = true;
        group = "media";
        openFirewall = true;
      };
    };

    networking = {
      firewall = {
        allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
        allowedTCPPorts = lib.mkIf cfg.nzbget.enable [ 6789 ];
      };
      wg-quick.interfaces = lib.mkIf cfg.deluge.enable {
        wg-p2p = {
          address = [ "10.2.0.2/32" ];
          autostart = true;
          dns = [ "10.10.1.100" "192.168.1.100" ];
          privateKeyFile = config.sops.secrets."wireguard/proton/p2p".path;
          peers = [
            {
              publicKey = "VEtFeCo88R26OwlJ+F1hwNOPhewYNJHL+S078L477Gk=";
              allowedIPs = [ "0.0.0.0/0" "::/0" ];
              endpoint = "79.127.169.59:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
