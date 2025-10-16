{
  config,
  lib,
  pkgs,
  users,
  system,
  ...
}:
let
  cfg = config.kp.virtualization;
  currentArchitecture = system;
  isUnstable = lib.versions.majorMinor lib.version == "25.11";
  ovmfCfg =
    if isUnstable then
      { }
    else
      {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
in
{
  options.kp.virtualization = {
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
        ovmf = ovmfCfg;
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
    boot.binfmt.emulatedSystems = lib.lists.remove currentArchitecture [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
