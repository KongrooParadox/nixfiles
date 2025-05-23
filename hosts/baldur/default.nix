{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    inputs.nixos-hardware.nixosModules.dell-inspiron-7405
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r zroot/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-path";
    };
  };

  services.xserver.xkb.layout = lib.mkForce "fr,ara,us";

  home-manager.users.fatiha.home.packages = [
    pkgs.zoom-us
  ];

  # Because zfs tries to load encryption keys before sops secret is available
  systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

  desktop = {
    enable = true;
    environment = "gnome";
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
    hostId = "050d02a0";
  };

  sops = {
    age = {
      keyFile = "/.age.txt";
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      "zfs-dataset/baldur/encrypted.key" = { };
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/.age.txt"
    ];
  };

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  system.language = "fr_FR";
  virtualization.enable = true;
}
