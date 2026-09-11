{
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware-configuration.nix
  ];

  kp = {
    desktop = {
      enable = true;
      environment = "gnome";
    };
    home-manager.enable = true;
    kids.enable = true;
    system.language = "fr_FR";
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  services.xserver.xkb.layout = lib.mkForce "fr,ara,us";

  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
