{ pkgs }:

pkgs.writeShellScriptBin "screen-capture" ''
  grim -g "$(slurp)" - | swappy -f -
''

