{ inputs, ... }:
let
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config = { };
      overlays = [ ];
    };
  };
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config = { };
      overlays = [
      ];
    };
  };
in
{
  default = final: prev: (stable-packages final prev) // (unstable-packages final prev);
  ddcutil-evdi = final: prev: {
    ddcutil = prev.ddcutil.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./ddcutil-evdi.patch ];
    });
  };
}
