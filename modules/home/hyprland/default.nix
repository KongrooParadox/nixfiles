{
  config,
  lib,
  pkgs,
  ...
}:
let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    dbus-update-activation-environment --systemd --all
    systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    ${pkgs.killall}/bin/killall -q swww;sleep 1 && ${pkgs.swww}/bin/swww-daemon &
    ${pkgs.killall}/bin/killall -q waybar;sleep 1 && waybar-launcher &
    ${pkgs.killall}/bin/killall -q swaync
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &
    ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policylit-agent &
    wl-paste --watch cliphist store &
  '';
in
{
  imports = [
    ./emoji.nix
    ./rofi.nix
    ./swaync.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  config = {
    home.packages = with pkgs; [
      cliphist
      wl-clipboard
      (import ../../../scripts/emoji-picker.nix { inherit pkgs; })
      (import ../../../scripts/task-waybar.nix { inherit pkgs; })
      (import ../../../scripts/web-search.nix { inherit pkgs; })
      (import ../../../scripts/rofi-launcher.nix { inherit pkgs; })
      (import ../../../scripts/rofi-clipboard-history.nix { inherit pkgs; })
      (import ../../../scripts/screen-capture.nix { inherit pkgs; })
      (import ../../../scripts/list-hypr-bindings.nix { inherit pkgs; })
      (import ../../../scripts/waybar-launcher.nix { inherit pkgs; })
    ];

    stylix.targets.hyprland.enable = false;
    programs.hyprlock.enable = true;
    services = {
      hyprpaper = {
        enable = true;
        settings = {
          ipc = "off";
          splash = false;
          splash_offset = 2.0;
          preload = [ "${../../../wallpapers/dark-nebula.jpg}" ];
          wallpaper = [
            ",${../../../wallpapers/dark-nebula.jpg}"
          ];
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      settings = {
        exec-once = ''${startupScript}/bin/start'';
      };
      extraConfig =
        let
          modifier = "SUPER";
        in
        lib.concatStrings [
          ''
            env = NIXOS_OZONE_WL, 1
            env = XDG_CURRENT_DESKTOP, Hyprland
            env = XDG_SESSION_TYPE, wayland
            env = XDG_SESSION_DESKTOP, Hyprland
            env = GDK_BACKEND, wayland, x11
            env = CLUTTER_BACKEND, wayland
            env = QT_QPA_PLATFORM=wayland;xcb
            env = QT_WAYLAND_DISABLE_WINDOWDECORATION, 1
            env = QT_AUTO_SCREEN_SCALE_FACTOR, 1
            env = SDL_VIDEODRIVER, x11
            env = MOZ_ENABLE_WAYLAND, 1
            monitor=eDP-1,2560x1600@60.0,4290x1685,1.6
            monitor=DVI-I-1,1920x1200@59.95,2410x105,1.0
            monitor=DVI-I-1,transform,1
            monitor=DVI-I-2,2560x1440@59.95,3610x245,1.0
            monitor=,preferred,auto,1
            general {
              gaps_in = 6
              gaps_out = 8
              border_size = 2
              layout = dwindle
              resize_on_border = true
              col.active_border = rgb(${config.stylix.base16Scheme.base08}) rgb(${config.stylix.base16Scheme.base0C}) 45deg
              col.inactive_border = rgb(${config.stylix.base16Scheme.base01})
            }
            input {
              kb_layout = us
              kb_variant = alt-intl
              kb_options = caps:escape
              follow_mouse = 1
              touchpad {
                natural_scroll = true
                disable_while_typing = true
                scroll_factor = 0.8
              }
              sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
              accel_profile = flat
            }
            windowrulev2 = noborder,class:^(wofi)$
            windowrulev2 = center,class:^(wofi)$
            windowrulev2 = center,class:^(steam)$
            windowrulev2 = float, class:nm-connection-editor|blueman-manager
            windowrulev2 = float, class:swayimg|vlc|Viewnior|pavucontrol
            windowrulev2 = float, class:nwg-look|qt5ct|mpv
            windowrulev2 = float, class:zoom
            windowrulev2 = stayfocused, title:^()$,class:^(steam)$
            windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
            windowrulev2 = opacity 0.9 0.7, class:^(Firefox)$
            windowrulev2 = opacity 0.9 0.7, class:^(thunar)$
            gestures {
              workspace_swipe = true
              workspace_swipe_fingers = 3
            }
            misc {
              initial_workspace_tracking = 0
              mouse_move_enables_dpms = true
              key_press_enables_dpms = false
            }
            animations {
              enabled = yes
              bezier = wind, 0.05, 0.9, 0.1, 1.05
              bezier = winIn, 0.1, 1.1, 0.1, 1.1
              bezier = winOut, 0.3, -0.3, 0, 1
              bezier = liner, 1, 1, 1, 1
              animation = windows, 1, 6, wind, slide
              animation = windowsIn, 1, 6, winIn, slide
              animation = windowsOut, 1, 5, winOut, slide
              animation = windowsMove, 1, 5, wind, slide
              animation = border, 1, 1, liner
              animation = fade, 1, 10, default
              animation = workspaces, 1, 5, wind
            }
            decoration {
              rounding = 10
              blur {
                  enabled = true
                  size = 5
                  passes = 3
                  new_optimizations = on
                  ignore_opacity = off
              }
            }
            plugin {
              hyprtrails {
              }
            }
            dwindle {
              pseudotile = true
              preserve_split = true
            }
            bind = ${modifier},0,workspace,10
            bind = ${modifier},1,workspace,1
            bind = ${modifier},2,workspace,2
            bind = ${modifier},3,workspace,3
            bind = ${modifier},4,workspace,4
            bind = ${modifier},5,workspace,5
            bind = ${modifier},6,workspace,6
            bind = ${modifier},7,workspace,7
            bind = ${modifier},8,workspace,8
            bind = ${modifier},9,workspace,9
            bind = ${modifier},B,exec,firefox
            bind = ${modifier},C,exec,hyprpicker -a
            bind = ${modifier},E,exec,thunar
            bind = ${modifier},F,fullscreen,
            bind = ${modifier},Q,killactive,
            bind = ${modifier},R,exec,rofi-launcher
            bind = ${modifier},S,exec,screen-capture
            bind = ${modifier},T,exec,alacritty
            bind = ${modifier},V,exec,rofi-clipboard-history
            bind = ${modifier},W,exec,waybar-launcher
            bind = ${modifier},H,movefocus,l
            bind = ${modifier},J,movefocus,d
            bind = ${modifier},K,movefocus,u
            bind = ${modifier},L,movefocus,r
            bind = ${modifier},SPACE,togglespecialworkspace
            bind = ${modifier},;,exec,emoji-picker
            bind = ${modifier},mouse_down,workspace, e+1
            bind = ${modifier},mouse_up,workspace, e-1
            bind = ${modifier}CONTROL,L,exec,hyprlock
            bind = ${modifier}CONTROL,left,workspace,e-1
            bind = ${modifier}CONTROL,right,workspace,e+1
            bind = ${modifier}SHIFT,0,movetoworkspace,10
            bind = ${modifier}SHIFT,1,movetoworkspace,1
            bind = ${modifier}SHIFT,2,movetoworkspace,2
            bind = ${modifier}SHIFT,3,movetoworkspace,3
            bind = ${modifier}SHIFT,4,movetoworkspace,4
            bind = ${modifier}SHIFT,5,movetoworkspace,5
            bind = ${modifier}SHIFT,6,movetoworkspace,6
            bind = ${modifier}SHIFT,7,movetoworkspace,7
            bind = ${modifier}SHIFT,8,movetoworkspace,8
            bind = ${modifier}SHIFT,9,movetoworkspace,9
            bind = ${modifier}SHIFT,B,exec,list-hypr-bindings
            bind = ${modifier}SHIFT,C,exit,
            bind = ${modifier}SHIFT,F,togglefloating,
            bind = ${modifier}SHIFT,I,togglesplit,
            bind = ${modifier}SHIFT,N,exec,swaync-client -rs
            bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
            bind = ${modifier}SHIFT,W,exec,web-search
            bind = ${modifier}SHIFT,H,movewindow,l
            bind = ${modifier}SHIFT,J,movewindow,d
            bind = ${modifier}SHIFT,K,movewindow,u
            bind = ${modifier}SHIFT,L,movewindow,r
            bindm = ${modifier},mouse:272,movewindow
            bindm = ${modifier},mouse:273,resizewindow
            bind = ALT,Tab,cyclenext
            bind = ALT,Tab,bringactivetotop
            bind = ,XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
            bind = ,XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
            binde = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
            bind = ,XF86AudioPlay, exec, playerctl play-pause
            bind = ,XF86AudioPause, exec, playerctl play-pause
            bind = ,XF86AudioNext, exec, playerctl next
            bind = ,XF86AudioPrev, exec, playerctl previous
            bind = ,XF86MonBrightnessDown,exec,brightnessctl set 5%-
            bind = ,XF86MonBrightnessUp,exec,brightnessctl set +5%
            bindl = , switch:on:Lid Switch, exec, hyprctl keyword monitor "eDP-1, disable"
            bindl = , switch:off:Lid Switch, exec, hyprctl keyword monitor "eDP-1, 2560x1600@60.0, auto, 1.25"
          ''
        ];
    };
  };
}
