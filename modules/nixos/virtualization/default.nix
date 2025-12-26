{
  config,
  lib,
  pkgs,
  users,
  ...
}:
let
  cfg = config.kp.virtualization;
in
{
  options.kp.virtualization = {
    enable = lib.mkEnableOption "Binfmt emulation for cross architecture compiling";

    bridgeInterfaceName = lib.mkOption {
      type = lib.types.str;
      example = "eno1";
      description = lib.mdDoc "Interface device name used for bridge of virtualization host";
    };

    libvirtd = {
      enable = lib.mkEnableOption "Libvirt & virt-manager";
    };
  };

  imports = [ ./proxmox.nix ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Enable emulation for other architectures
      boot.binfmt.emulatedSystems = lib.lists.remove config.nixpkgs.hostPlatform.system [
        "x86_64-linux"
        "aarch64-linux"
      ];
    })

    (lib.mkIf cfg.proxmox.enable or cfg.libvirtd.enable {
      networking = {
        bridges = {
          "br0" = {
            interfaces = [ cfg.bridgeInterfaceName ];
          };
        };
        interfaces."br0".useDHCP = true;
        useDHCP = false;
      };
    })

    (lib.mkIf cfg.libvirtd.enable {
      programs.virt-manager = {
        enable = true;
      };
      users.users = builtins.listToAttrs (
        map (user: {
          name = user;
          value.extraGroups = [ "libvirtd" ];
        }) users
      );
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
    })
  ];
}
