{
  config,
  domain,
  lib,
  ...
}:
let
  cfg = config.kp.arr;
  isUnstable = lib.versions.majorMinor lib.version >= "25.11";
  prowlarrCfg =
    if isUnstable then
      {
        dataDir = "${cfg.computeBasePath}/prowlarr";
        enable = true;
        openFirewall = true;
      }
    else
      {
        enable = true;
        openFirewall = true;
      };
in
{
  options.kp.arr = {
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
        default = "wg-arr-tavel";
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

    mediaBasePath = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/media";
      example = "/var/lib/media";
      description = lib.mdDoc ''
        Base path of media folder (used for downloads).
      '';
    };

    computeBasePath = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.computeBasePath}";
      example = "/var/lib/compute";
      description = lib.mdDoc ''
        Base path for arr apps (aka compute path).
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
        "newshosting/username" = { };
        "newshosting/password" = { };
      })
      (lib.mkIf cfg.deluge.enable {
        "deluge-auth" = {
          mode = "0440";
          group = "media";
        };
        "wireguard/proton/arr-tavel" = { };
        "wireguard/proton/p2p-2" = { };
      })
    ];

    # https://github.com/NixOS/nixpkgs/issues/360592 - Sonar still uses EOL .net 6.0
    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];
    users.groups.media = { };

    kp = {
      impermanence = lib.mkIf config.kp.impermanence.enable {
        extraDirectories =
          lib.optionals (!lib.strings.hasPrefix "/mnt" cfg.mediaBasePath) [ cfg.mediaBasePath ]
          ++ lib.optionals (!lib.strings.hasPrefix "/mnt" cfg.computeBasePath) [ cfg.computeBasePath ]
          ++ lib.optionals cfg.nzbget.enable [ "/var/lib/nzbget" ]
          ++ lib.optionals cfg.prowlarr.enable [
            "${cfg.computeBasePath}/prowlarr"
            "/var/lib/private"
          ];
      };
      reverseProxy = {
        enable = true;
        domain = cfg.domain;
        services = {
          deluge.port = 8112;
          lidarr.port = 8686;
          nzbget.port = 6789;
          prowlarr.port = 9696;
          radarr.port = 7878;
          readarr.port = 8787;
          sonarr.port = 8989;
        };
      };
      tailscale = lib.mkIf cfg.deluge.enable {
        enable = lib.mkForce false;
      };
    };

    services = {
      deluge = lib.mkIf cfg.deluge.enable {
        authFile = config.sops.secrets."deluge-auth".path;
        config = {
          allow_remote = false;
          download_location = "${cfg.mediaBasePath}/downloads/torrents/current";
          max_half_open_connections = 100;
          max_connections_per_second = 100;
          move_completed = true;
          move_completed_path = "${cfg.mediaBasePath}/downloads/torrents/completed";
          outgoing_interface = cfg.deluge.wireguardInterface;
          pre_allocate_storage = false; # ZFS doesn't support fallocate
          torrentfiles_location = "${cfg.mediaBasePath}/downloads/torrents/files";
          enabled_plugins = [ "Label" ];
        };
        dataDir = "${cfg.computeBasePath}/deluge/";
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

      prowlarr = lib.mkIf cfg.prowlarr.enable prowlarrCfg;

      radarr = lib.mkIf cfg.radarr.enable {
        dataDir = "${cfg.computeBasePath}/radarr/.config/Radarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      readarr = lib.mkIf cfg.readarr.enable {
        dataDir = "${cfg.computeBasePath}/readarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      sonarr = lib.mkIf cfg.sonarr.enable {
        dataDir = "${cfg.computeBasePath}/sonarr/.config/Sonarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      lidarr = lib.mkIf cfg.lidarr.enable {
        dataDir = "${cfg.computeBasePath}/lidarr/.config/Lidarr";
        enable = true;
        group = "media";
        openFirewall = true;
      };

      nzbget = lib.mkIf cfg.nzbget.enable {
        enable = true;
        group = "media";
        settings = {
          MainDir = "${cfg.mediaBasePath}/downloads";
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
        wg-arr-tavel = lib.mkIf (cfg.deluge.wireguardInterface == "wg-arr-tavel") {
          address = [ "10.2.0.2/32" ];
          autostart = true;
          dns = [
            "192.168.2.100"
            "192.168.1.100"
          ];
          privateKeyFile = config.sops.secrets."wireguard/proton/arr-tavel".path;
          peers = [
            {
              # FR#501
              publicKey = "hr/tdXvYAhoX6gCmdViw+uLXIYfGuC4W0kOIwagj0Dk=";
              allowedIPs = [
                "0.0.0.0/0"
                "::/0"
              ];
              endpoint = "178.249.212.170:51820";
              persistentKeepalive = 25;
            }
          ];
        };
        wg-p2p-2 = lib.mkIf (cfg.deluge.wireguardInterface == "wg-p2p-2") {
          address = [ "10.2.0.2/32" ];
          autostart = true;
          dns = [
            "192.168.2.100"
            "192.168.1.100"
          ];
          privateKeyFile = config.sops.secrets."wireguard/proton/p2p-2".path;
          peers = [
            {
              publicKey = "JsWZdbNQ38Enz3AYGJLI6HVF5I5RqfrIkkcwsznAGSs=";
              allowedIPs = [
                "0.0.0.0/0"
                "::/0"
              ];
              endpoint = "146.70.194.50:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
