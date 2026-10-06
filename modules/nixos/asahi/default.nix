{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.kp.asahi;
in
{
  options.kp.asahi = {
    enable = lib.mkEnableOption "asahi drivers.";
    steam = {
      enable = lib.mkEnableOption "steam-asahi flake.";
    };
  };

  imports = [
    ./steam-asahi.nix
  ];

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.crun.version == "1.30.1";
        message = "Remove the temporary crun large-page overlay from modules/nixos/asahi/default.nix; upstream now includes the fix.";
      }
    ];

    nixpkgs.overlays = [
      inputs.apple-silicon.overlays.apple-silicon-overlay
      (final: prev: {
        crun = prev.crun.overrideAttrs (old: {
          patches =
            (old.patches or [ ])
            ++ lib.optional (old.version == "1.30.1") (
              inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.fetchpatch {
                url = "https://github.com/containers/crun/commit/ece7b66bff5a65bfca33b64cd9da7f9eaf043c55.patch";
                hash = "sha256-FZc+toizNHhpWUj8Kec3maNd8wrRr2m0y0w0FBw52k4=";
              }
            );
        });
      })
    ];

    environment = {
      sessionVariables.AQ_DRM_DEVICES = lib.mkForce "/dev/dri/card2";
    };

    hardware = {
      asahi = {
        enable = true;
        # Speakers and the ambient light sensor only matter on a desktop
        setupAsahiSound = config.kp.desktop.enable;
      };
      sensor.iio.enable = config.kp.desktop.enable;
      # Provide the Asahi Mesa GPU userspace (incl. the Honeykrisp Vulkan ICD in
      # /run/opengl-driver) so any Asahi host can use the GPU (e.g. llama.cpp).
      graphics.enable = lib.mkDefault true;
    };
    powerManagement = {
      powertop.enable = lib.mkForce false;
    };

    nix.settings = {
      extra-substituters = [
        "https://nixos-apple-silicon.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };
  };
}
