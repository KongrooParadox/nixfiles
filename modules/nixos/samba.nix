{ config, host, lib, username, workgroup, ... }:

let
  cfg = config.samba;
in
{
  options.samba = {
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

  config = lib.mkIf cfg.enable {
    sops.secrets.michel-password.neededForUsers = true;
    users.users.michel = {
      hashedPasswordFile = config.sops.secrets.michel-password.path;
      extraGroups = [ "media" ];
      isNormalUser = true;
      group = cfg.group;
    };
    users.users.${username} = {
      extraGroups = [ cfg.group ];
    };
    users.users.${cfg.user} = {
      extraGroups = [ "media" ];
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = {};

    services.samba = {
      enable = true;
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
          "valid users" = "+${cfg.group}";
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
          "force user" = cfg.user;
          "force group" = cfg.group;
        };
        "compute" = {
          "path" = "/mnt/compute";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = cfg.user;
          "force group" = cfg.group;
        };
        "media" = {
          "path" = "/mnt/media";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0755";
          "force user" = cfg.user;
          "force group" = "media";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };

}
