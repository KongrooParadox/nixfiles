{ lib, modulesPath, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  imports = [
    (modulesPath + "/virtualisation/oci-image.nix")
  ];

  services.cloud-init.enable = true;
}
