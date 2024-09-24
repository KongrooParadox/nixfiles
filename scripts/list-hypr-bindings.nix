{ pkgs, ... }:

pkgs.writeShellScriptBin "list-hypr-bindings" ''
  yad --width=800 --height=650 \
  --center \
  --fixed \
  --title="Hyprland Keybindings" \
  --no-buttons \
  --list \
  --column=Key: \
  --column=Description: \
  --column=Command: \
  --timeout=90 \
  --timeout-indicator=right \
  " = Super" "Modifier Key, used for keybindings" "Doesn't really execute anything by itself." \
  " + B" "Launch Web Browser" "firefox" \
  " + D" "App Launcher" "rofi" \
  " + E" "Launch Emoji Selector" "emoji-picker" \
  " + F" "Toggle Focused Fullscreen" "fullscreen" \
  " + H" "Move Focus To Window On The Left" "movefocus,l" \
  " + J" "Move Focus To Window On The Down" "movefocus,d" \
  " + K" "Move Focus To Window On The Up" "movefocus,u" \
  " + L" "Move Focus To Window On The Right" "movefocus,r" \
  " + Q" "Kill Focused Window" "killactive" \
  " + S" "Take Screenshot" "screen-capture" \
  " + T" "Terminal" "alacritty" \
  " + V" "Search through clipboard history" "cliphist list" \
  " + 1-0" "Move To Workspace 1 - 10" "workspace,X" \
  " + SHIFT + 1-0" "Move Focused Window To Workspace 1 - 10" "movetoworkspace,X" \
  " + SHIFT + C" "Quit / Exit Hyprland" "exit" \
  " + SHIFT + F" "Toggle Focused Floating" "fullscreen" \
  " + SHIFT + H" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + J" "Move Focused Window Down" "movewindow,d" \
  " + SHIFT + K" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + L" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + N" "Reload SwayNC Styling" "swaync-client -rs" \
  " + SHIFT + SPACE" "Send Focused Window To Special Workspace" "movetoworkspace,special" \
  " + SHIFT + W" "Search Websites Like Nix Packages" "web-search" \
  " + SPACE" "Toggle Special Workspace" "togglespecialworkspace" \
  " + MOUSE_LEFT" "Move/Drag Window" "movewindow" \
  " + MOUSE_RIGHT" "Resize Window" "resizewindow" \
  "ALT + TAB" "Cycle Window Focus + Bring To Front" "cyclenext & bringactivetotop" \
  ""
''

