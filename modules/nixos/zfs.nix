{
  config,
  host,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.kp.zfs;
  diskoFile = "${self}/hosts/${host}/disks.nix";
in
{
  options.kp = {
    zfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to enable zfs module";
      };
      encryptionKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = lib.mdDoc "List of encryption keys for zfs datasets in sops secrets";
      };
      hostId = lib.mkOption {
        type = lib.types.str;
        example = "";
        description = lib.mdDoc "The 32-bit host ID of the machine, formatted as 8 hexadecimal characters";
      };
    };
  };

  imports =
    if builtins.pathExists diskoFile then
      [
        diskoFile
        inputs.disko.nixosModules.disko
      ]
    else
      [ ];

  config = lib.mkIf cfg.enable {
    boot = {
      initrd = {
        systemd.services.impermanence = lib.mkIf config.kp.impermanence.enable {
          description = "wipe root dataset";
          serviceConfig.Type = "oneshot";
          after = [
            "initrd-root-device.target"
            "zfs-import-zpool.service"
          ];
          requires = [
            "initrd-root-device.target"
            "zfs-import-zpool.service"
          ];
          before = [ "sysroot.mount" ];
          wantedBy = [ "initrd.target" ];
          script = ''
            ${pkgs.zfs}/bin/zfs rollback -r ${config.fileSystems."/".device}@blank
          '';
        };
        secrets = lib.mkIf (cfg.encryptionKeys != [ ]) (
          builtins.listToAttrs (
            map (key: {
              name = "/run/secrets/zfs-dataset/${host}/${key}";
              value = null; # null means path value is the same as it's attribute name
            }) cfg.encryptionKeys
          )
        );
      };
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/disk/by-path";
        forceImportRoot = false;
      };
    };

    networking = {
      hostId = cfg.hostId;
    };

    sops = lib.mkIf (cfg.encryptionKeys != [ ]) {
      secrets = builtins.listToAttrs (
        map (key: {
          name = "zfs-dataset/${host}/${key}";
          value = { };
        }) cfg.encryptionKeys
      );
    };
  };
}
