{ pkgs }:

pkgs.writeShellScriptBin "fleeting-note" ''
  noteContent=$( (echo) | ${pkgs.rofi}/bin/rofi -i -dmenu -p "📒 Fleeting note :" -theme-str 'listview { enabled: false; }')
  obsidianVaultDir="''${HOME}/src/digital-garden"
  noteFile="''${obsidianVaultDir}/''${noteContent}.md"
  ${pkgs.obsidian}/bin/obsidian-cli vault=digital-garden quickadd:run choice="Fleeting" value-value="''${noteContent}"
  # No Obsidian instance running, we manually record the fleeting Note
  if [[ "$?" == 1 ]]; then
    cat "''${obsidianVaultDir}/meta/templates/Fleeting note template.md" | sed "s/{{VALUE}}/''${noteContent}/g" > "''${noteFile}"
  fi
''
