{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    inputs.apple-silicon.nixosModules.default
    ../../modules/nixos/asahi
    ./hardware-configuration.nix
  ];
  boot = {
    supportedFilesystems = [ "bcachefs" ];
    initrd = {
      supportedFilesystems = ["bcachefs"];
      availableKernelModules = ["bcache"];
    };
  };

  nixpkgs.overlays = [
    inputs.apple-silicon.overlays.apple-silicon-overlay
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  desktop.enable = false;
  hm.enable = false;
  podman.enable = true;
  virtualization.enable = true;

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
