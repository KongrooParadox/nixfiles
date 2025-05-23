{
  config,
  desktop,
  lib,
  pkgs,
  ...
}:
{
  # TODO: temporary hack from https://github.com/nix-community/home-manager/issues/1341#issuecomment-778820334
  # Even though nix-darwin support symlink to ~/Application or ~/Application/Nix Apps
  # Spotlight doesn't like symlink as all or it won't index them
  home.activation = lib.mkIf (desktop.environment == "macos") {
    copyApplications =
      let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        baseDir="$HOME/Applications/Home Manager Apps"
        if [ -d "$baseDir" ]; then
          rm -rf "$baseDir"
        fi
        mkdir -p "$baseDir"
        for appFile in ${apps}/Applications/*; do
          target="$baseDir/$(basename "$appFile")"
          $DRY_RUN_CMD cp ''${VERBOSE_ARG:+-v} -fHRL "$appFile" "$baseDir"
          $DRY_RUN_CMD chmod ''${VERBOSE_ARG:+-v} -R +w "$target"
        done
      '';
  };
}
