{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
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

  # Because zfs tries to load encryption keys before sops secret is available
  systemd.services.zfs-mount.serviceConfig.ExecStartPre = ''
    ${pkgs.zfs}/bin/zfs load-key -a
  '';

  desktop = {
    enable = true;
    environment = "plasma";
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
    hostId = "050d02a0";
  };

  sops = {
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      "zfs-dataset/baldur/encrypted.key" = {};
      "users/fatiha/password".neededForUsers = true;
    };
  };

  users.users = {
    fatiha = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Fatiha";
      extraGroups = [ "wheel" "video" ];
      hashedPasswordFile = config.sops.secrets."users/fatiha/password".path;
      openssh.authorizedKeys.keys = (import ../../modules/nixos/ssh.nix).keys;
    };
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

  virtualization.enable = true;
}
