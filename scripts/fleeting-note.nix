{ pkgs }:

pkgs.writeShellScriptBin "fleeting-note" ''
  noteContent=$( (echo) | ${pkgs.rofi}/bin/rofi -i -dmenu -p "📒 Fleeting note :" -theme-str 'listview { enabled: false; }')
  ${pkgs.obsidian}/bin/obsidian-cli vault=digital-garden quickadd:run choice="Fleeting" value-value="''${noteContent}"
''
