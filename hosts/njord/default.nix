{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r zpool/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-id";
    };
  };

  nixpkgs.overlays = [
    inputs.apple-silicon.overlays.apple-silicon-overlay
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  desktop.enable = true;
  hm.enable = true;
  podman.enable = true;
  virtualization.enable = true;

  networking.hostId = "720320e5";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  sops = {
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
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
    ];
  };
  sops.secrets."wireguard/proton/ar-25" = { };
  networking.wg-quick.interfaces.wg-ar-25 = {
    address = [ "10.2.0.2/32" ];
    autostart = false;
    dns = [
      "10.10.111.100"
      "192.168.1.100"
    ];
    privateKeyFile = config.sops.secrets."wireguard/proton/ar-25".path;
    peers = [
      {
        publicKey = "pPR96SBtq9grARK6XDm5WI3XP1d8Le19Jl/HA9p7o00=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "149.102.224.161:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  services = {
    openssh = {
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
  };

  samba.client.enable = true;
}
