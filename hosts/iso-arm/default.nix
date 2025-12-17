{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  imports = [ ../../modules/nixos/installer.nix ];
}
