{ config, ... }:
{
  imports = [
    ./fonts.nix
    ./home-manager.nix
    ./stylix.nix
  ];

  sops.secrets."github/api-key" = { };

  nix = {
    extraOptions = ''
      !include ${config.sops.secrets."github/api-key".path}
    '';
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
