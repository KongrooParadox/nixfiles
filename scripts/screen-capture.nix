{ pkgs }:

pkgs.writeShellScriptBin "screen-capture" ''
  ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -
''

