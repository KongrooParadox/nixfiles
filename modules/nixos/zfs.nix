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
    };
  };

  imports = [
    "${self}/hosts/${host}/disks.nix"
    inputs.disko.nixosModules.disko
  ];

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.postResumeCommands = lib.mkAfter ''
        zfs rollback -r zroot/root@blank
      '';
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/disk/by-path";
      };
    };

    # Because zfs tries to load encryption keys before sops secret is available
    systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
      ${pkgs.zfs}/bin/zfs load-key -a
    '';

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
