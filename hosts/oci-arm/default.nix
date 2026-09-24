{ lib, modulesPath, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  kp.tailscale.enable = false;

  imports = [
    (modulesPath + "/virtualisation/oci-image.nix")
  ];

  services.cloud-init.enable = true;
}
