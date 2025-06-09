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

  services.xserver.xkb.layout = lib.mkForce "fr,ara,us";

  desktop = {
    enable = true;
    environment = "gnome";
  };

  hm.enable = true;

  networking = {
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  sops = {
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };

  system.language = "fr_FR";
}
