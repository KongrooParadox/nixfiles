{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  imports = [
    inputs.nixos-avf.nixosModules.avf
  ];

  avf = {
    # The default user is fully defined by modules/nixos/users.nix (sops
    # password); avf only needs to know which user the console logs into.
    defaultUser = "ops";
    # Headless media server: the Terminal app UI is the console, not Weston.
    enableGraphics = false;
    # Mainline kernel, no AVF patches: the Terminal app VM is a regular
    # (non-protected) crosvm guest, so the pKVM balloon/psp stuff and the
    # Android cpufreq display are not needed; every virtio device is mainline.
    useGenericKernel = true;
  };

  # avf creates its default user with an empty password; the real password
  # comes from sops via modules/nixos/users.nix.
  users.users.ops.initialHashedPassword = lib.mkForce null;

  # The AVF image boots systemd-boot from the ESP without EFI variable
  # support.
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # Android 17 Terminal boots a fixed kernel+initrd (no EFI) and hands off to
  # /sbin/init; the avf module (android-17 shape) generates the stage-2
  # handoff script. modules/nixos/boot.nix enables systemd-boot for every
  # host; the initScript handoff must be the only bootloader (NixOS allows
  # exactly one).
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_7_3;

  # Impermanence: / is an empty tmpfs on every boot; the avf disk keeps /nix
  # and everything declared persistent under /persist. Nothing here touches
  # /mnt/shared (virtiofs export of Android's shared storage).
  fileSystems = {
    "/" = lib.mkForce {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "mode=755" ];
    };
    "/persist" = {
      # Android 17 exposes the root fs as /dev/vda1 (no udev modules, so no
      # by-label lookup); see nixos-avf#42.
      device = "/dev/vda1";
      fsType = "ext4";
      autoResize = true;
      neededForBoot = true;
    };
    "/nix" = {
      device = "/persist/nix";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  # Roaming host: addressing and DNS come from Android's DHCP and Tailscale,
  # never from the oujda site resolvers.
  networking = {
    nameservers = lib.mkForce [ ];
    useNetworkd = lib.mkForce true;
  };

  kp = {
    impermanence.enable = true;
    media-player = {
      enable = true;
      dataDir = "/var/lib/jellyfin";
    };
    reverseProxy.tls = {
      mode = "tailscale";
      tailnet = "leopard-regulus.ts.net";
    };
    tailscale.autoconnect = true;
  };
}
