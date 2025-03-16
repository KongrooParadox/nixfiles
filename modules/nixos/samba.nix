{ config, domain, host, lib, pkgs, users, workgroup, ... }:

let
  cfg = config.samba;
  # Prevent hanging on network split
  automount_opts = user: "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,credentials=${config.sops.secrets."smb/${user}".path}";
in
{
  options.samba = {
    server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable Samba server";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "samba";
        description = lib.mdDoc "User for samba file mapping";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "samba";
        description = lib.mdDoc "Group for samba file mapping";
      };
    };
    client = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable Samba client";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      sops.secrets = (builtins.listToAttrs (
        map (user: {
          name = "users/${user}/password";
          value.neededForUsers = true;
        }) users
      )) // {
        "users/michel/password".neededForUsers = true;
        "users/robot/password".neededForUsers = true;
      };

      users = {
        users = (builtins.listToAttrs (
          map (user: {
            name = user;
            value = {
              hashedPasswordFile = config.sops.secrets."users/${user}/password".path;
              extraGroups = [ "media" ];
              isNormalUser = true;
              group = cfg.server.group;
            };
          }) users
        )) // {
          michel = {
            hashedPasswordFile = config.sops.secrets."users/michel/password".path;
            extraGroups = [ "media" ];
            isNormalUser = true;
            group = cfg.server.group;
          };
          robot = {
            hashedPasswordFile = config.sops.secrets."users/robot/password".path;
            extraGroups = [ "media" ];
            isNormalUser = true;
            group = cfg.server.group;
          };
          ${cfg.server.user} = {
            extraGroups = [ "media" ];
            isSystemUser = true;
            group = cfg.server.group;
          };
        };
        groups.${cfg.server.group} = {};
      };

      services = {
        samba = {
          enable = true;
          package = pkgs.samba4Full;
          openFirewall = true;
          settings = {
            global = {
              workgroup = workgroup;
              "server string" = host;
              "netbios name" = host;
              security = "user";
              #"use sendfile" = "yes";
              #"max protocol" = "smb2";
              # note: localhost is the ipv6 localhost ::1
              "hosts allow" = "192.168.1. 10.10.111. 127.0.0.1 localhost";
              "valid users" = "+${cfg.server.group}";
              "hosts deny" = "0.0.0.0/0";
              "guest account" = "nobody";
              "map to guest" = "bad user";
            };
            "backup" = {
              "path" = "/mnt/backup";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = cfg.server.user;
              "force group" = cfg.server.group;
            };
            "compute" = {
              "path" = "/mnt/compute";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = cfg.server.user;
              "force group" = cfg.server.group;
            };
            "media" = {
              "path" = "/mnt/media";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0664";
              "directory mask" = "0755";
              "force user" = cfg.server.user;
              "force group" = "media";
            };
          };
        };
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
        avahi = {
          enable = true;
          nssmdns4 = true;
          # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
          openFirewall = true;
          publish.enable = true;
          publish.userServices = true;
          # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
        };
      };
    })
    (lib.mkIf cfg.client.enable {
      sops.secrets = builtins.listToAttrs (
        map (user: {
          name = "smb/${user}";
          value = {};
        }) users
      );

      environment.systemPackages = [ pkgs.cifs-utils ];

      fileSystems = builtins.listToAttrs (
        builtins.concatMap (user: [
          {
            name = "/mnt/share/backup";
            value = {
              device = "//smb.${domain}/backup";
              fsType = "cifs";
              options = [ (automount_opts user) ];
            };
          }
          {
            name = "/mnt/share/compute";
            value = {
              device = "//smb.${domain}/compute";
              fsType = "cifs";
              options = [ (automount_opts user) ];
            };
          }
          {
            name = "/mnt/share/media";
            value = {
              device = "//smb.${domain}/media";
              fsType = "cifs";
              options = [ (automount_opts user) ];
            };
          }
        ]) users
      );
    })
  ];
}

