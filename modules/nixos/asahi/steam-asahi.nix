{
  config,
  inputs,
  users,
  lib,
  ...
}:
let
  cfg = config.kp.asahi.steam;
in
{
  imports = [
    inputs.steam-asahi.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePackages = [
      "steam-asahi"
      "steam-asahi-arm64"
      "steam-arm64-client"
      "steam-unwrapped"
    ];

    programs.steam-asahi = {
      enable = true;
      backend = "arm64"; # "x86-fex"
      memoryMiB = 10 * 1024; # 10 GiB for RAM
      vramMiB = 8 * 1024; # GPU heap size reported inside the guest
    };

    users.users = builtins.listToAttrs (
      map (user: {
        name = user;
        value = {
          extraGroups = [ "kvm" ];
        };
      }) users
    );

    #   swapDevices = [
    #     {
    #       device = "/var/lib/swapfile";
    #       size = 12 * 1024; # MiB
    #     }
    #   ];
    #
    #   boot.kernelParams = [
    #     "zswap.enabled=1"
    #     "zswap.compressor=zstd"
    #     "zswap.zpool=zsmalloc"
    #     "zswap.max_pool_percent=20"
    #   ];
    #
    #   boot.kernel.sysctl = {
    #     "vm.swappiness" = 100;
    #     "vm.page-cluster" = 0;
    #     "vm.watermark_scale_factor" = 125;
    #     "vm.max_map_count" = 1048576;
    #   };
  };
}
