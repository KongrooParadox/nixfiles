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
      initrd.postResumeCommands = lib.mkAfter ''
        zfs rollback -r zroot/root@blank
      '';
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/disk/by-path";
      };
    };

    # Because zfs tries to load encryption keys before sops secret is available
    system.activationScripts.loadZfsEncryptionKeys = lib.mkIf (cfg.encryptionKeys != [ ]) (
      lib.stringAfter [ "setupSecrets" ] "${pkgs.zfs}/bin/zfs load-key -a"
    );

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
