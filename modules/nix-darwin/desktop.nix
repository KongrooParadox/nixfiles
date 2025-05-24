{ lib, ... }:
{
  options.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable desktop-specific config";
    };
    environment = lib.mkOption {
      type = lib.types.enum [ "macos" ];
      default = "macos";
      description = lib.mdDoc "Which Desktop Environment to install (macos)";
    };
  };
}
