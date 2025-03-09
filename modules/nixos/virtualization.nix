{ config, lib, pkgs, users, ... }:
let
  cfg = config.virtualization;
  currentArchitecture = config.nixpkgs.system;
in
{
  options.virtualization = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable libvirt virtualization";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
            }).fd];
        };
      };
    };

    programs.virt-manager.enable = true;

    users.users = builtins.listToAttrs (
      map (user: {
        name = user;
        value.extraGroups = [ "libvirtd" ];
      }) users
    );

    # Enable emulation for other architectures
    boot.binfmt.emulatedSystems = lib.lists.remove currentArchitecture [ "x86_64-linux" "aarch64-linux" ];
  };
}
