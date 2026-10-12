{ lib, pkgs, ... }:
let
  sunshineGamescopeMode = pkgs.writeShellApplication {
    name = "sunshine-gamescope-mode";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.util-linux
    ];
    text = builtins.readFile ./sunshine-gamescope-mode.sh;
  };
  sunshinePlasmaRebind = pkgs.writeShellApplication {
    name = "sunshine-plasma-rebind";
    runtimeInputs = [ pkgs.systemd ];
    text = ''
      systemctl --user restart sunshine.service
    '';
  };
in
{
  nixpkgs.overlays = lib.mkAfter [
    (final: prev: {
      jovianPackages = prev.jovianPackages.overrideScope (jovianFinal: jovianPrev: {
        gamescope-session = jovianPrev.gamescope-session.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./gamescope-session-resolution.patch ];
        });
      });
    })
  ];

  environment.systemPackages = [ sunshineGamescopeMode ];

  environment.etc."xdg/autostart/mjolnir-sunshine-plasma-rebind.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Sunshine display handoff
    Exec=${sunshinePlasmaRebind}/bin/sunshine-plasma-rebind
    Terminal=false
    NoDisplay=true
    OnlyShowIn=KDE;
  '';

  systemd.user.services.sunshine.partOf = lib.mkForce [ ];

  services.sunshine.applications.apps = [
    {
      name = "Desktop";
    }
    {
      name = "Steam (client resolution)";
      prep-cmd = [
        {
          do = "${sunshineGamescopeMode}/bin/sunshine-gamescope-mode set-client";
          undo = "${sunshineGamescopeMode}/bin/sunshine-gamescope-mode restore";
        }
      ];
    }
  ];
}
