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
  " = Windows/Super/CAPS LOCK" "Modifier Key, used for keybindings" "Doesn't really execute anything by itself." \ " + T" "Terminal" "alacritty" \
  " + D" "App Launcher" "rofi" \
  " + Q" "Kill Focused Window" "killactive" \
  " + SHIFT + W" "Search Websites Like Nix Packages" "web-search" \
  " + SHIFT + N" "Reload SwayNC Styling" "swaync-client -rs" \
  " + B" "Launch Web Browser" "firefox" \
  " + E" "Launch Emoji Selector" "emoji-picker" \
  " + S" "Take Screenshot" "screen-capture" \
  " + F" "Toggle Focused Fullscreen" "fullscreen" \
  " + SHIFT + F" "Toggle Focused Floating" "fullscreen" \
  " + SHIFT + C" "Quit / Exit Hyprland" "exit" \
  " + H" "Move Focus To Window On The Left" "movefocus,l" \
  " + L" "Move Focus To Window On The Right" "movefocus,r" \
  " + K" "Move Focus To Window On The Up" "movefocus,u" \
  " + J" "Move Focus To Window On The Down" "movefocus,d" \
  " + SHIFT + H" "Move Focused Window Left" "movewindow,l" \
  " + SHIFT + L" "Move Focused Window Right" "movewindow,r" \
  " + SHIFT + K" "Move Focused Window Up" "movewindow,u" \
  " + SHIFT + J" "Move Focused Window Down" "movewindow,d" \
  " + SPACE" "Toggle Special Workspace" "togglespecialworkspace" \
  " + SHIFT + SPACE" "Send Focused Window To Special Workspace" "movetoworkspace,special" \
  " + 1-0" "Move To Workspace 1 - 10" "workspace,X" \
  " + SHIFT + 1-0" "Move Focused Window To Workspace 1 - 10" "movetoworkspace,X" \
  " + MOUSE_LEFT" "Move/Drag Window" "movewindow" \
  " + MOUSE_RIGHT" "Resize Window" "resizewindow" \
  "ALT + TAB" "Cycle Window Focus + Bring To Front" "cyclenext & bringactivetotop" \
  ""
''

