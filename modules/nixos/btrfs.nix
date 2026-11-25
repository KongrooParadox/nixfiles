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
  cfg = config.kp.btrfs;
  diskoFile = "${self}/hosts/${host}/disks.nix";
in
{
  options.kp = {
    btrfs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the btrfs module (LUKS2 + btrfs subvolumes via disko).";
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
      supportedFilesystems = [ "btrfs" ];
      initrd = {
        supportedFilesystems = [ "btrfs" ];
        systemd.services.impermanence = lib.mkIf config.kp.impermanence.enable {
          description = "wipe root subvolume";
          serviceConfig.Type = "oneshot";
          after = [ "initrd-root-device.target" ];
          requires = [ "initrd-root-device.target" ];
          before = [ "sysroot.mount" ];
          wantedBy = [ "initrd.target" ];
          # The btrfs root subvolume is recreated empty on every boot, so
          # anything not under /persist or /home is discarded (impermanence).
          script = ''
            mkdir -p /mnt
            mount -o subvol=/,compress=zstd ${config.fileSystems."/".device} /mnt
            ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /mnt/@root
            ${pkgs.btrfs-progs}/bin/btrfs subvolume create /mnt/@root
            umount /mnt
          '';
        };
      };
    };
  };
}