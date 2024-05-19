{
  description = "flake for baldur-nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-hardware, sops-nix, ... }@inputs: {
    nixosConfigurations.baldur-nix = nixpkgs.lib.nixosSystem {
      system = "x86-64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        ./greetd.nix
        sops-nix.nixosModules.sops {
          sops = {
            age.keyFile = "/home/robot/.config/sops/age/keys.txt";
            defaultSopsFile = ./secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."wireguard/casa-anita" = {};
            secrets."wireguard/home" = {};
          };
        }
        nixos-hardware.nixosModules.dell-inspiron-7405
        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.robot = { pkgs, ... }: {
              home.username = "robot";
              home.homeDirectory = "/home/robot";
              home.file = {
                "libvirt.conf" = {
                  source = ./libvirt;
                  target = ".config/libvirt";
                };
                "nvim" = {
                  source = ./nvim;
                  target = ".config/nvim";
                  recursive = true;
                };
                "scripts" = {
                  source = ./bin;
                  target = ".local/bin";
                };
              };
              programs = {
                alacritty = {
                  enable = true;
                  settings = {
                    env.TERM = "alacritty";
                    window = {
                      decorations = "full";
                      title = "Alacritty";
                      dynamic_title = true;
                      class = {
                        instance = "Alacritty";
                        general = "Alacritty";
                      };
                    };
                    font = {
                      normal = {
                        family = "FiraCodeNerdFont";
                        style = "regular";
                      };
                      bold = {
                        family = "FiraCodeNerdFont";
                        style = "Bold";
                      };
                      italic = {
                        family = "FiraCodeNerdFont";
                        style = "Italic";
                      };
                      bold_italic = {
                        family = "FiraCodeNerdFont";
                        style = "Bold Italic";
                      };
                      size = 14.00;
                    };
                    colors = {
                      primary = {
                        background = "#1d1f21";
                        foreground = "#c5c8c6";
                      };
                    };
                  };
                };
                direnv = {
                  enable = true;
                  enableZshIntegration = true;
                  enableBashIntegration = true;
                };
                firefox = {
                  enable = true;
                  profiles.default = {
                    id = 0;
                    name = "default";
                    settings = {
                      "browser.startup.homepage" = "https://github.com/KongrooParadox";
                      "dom.security.https_only_mode" = true;
                      "dom.security.https_only_mode_ever_enabled" = true;
                      "privacy.donottrackheader.enabled" = true;
                      "privacy.trackingprotection.enabled" = true;
                      "privacy.trackingprotection.socialtracking.enabled" = true;
                      "privacy.partition.network_state.ocsp_cache" = true;
                      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
                      "browser.newtabpage.activity-stream.telemetry" = false;
                      "browser.ping-centre.telemetry" = false;
                      "toolkit.telemetry.archive.enabled" = false;
                      "toolkit.telemetry.bhrPing.enabled" = false;
                      "toolkit.telemetry.enabled" = false;
                      "toolkit.telemetry.firstShutdownPing.enabled" = false;
                      "toolkit.telemetry.hybridContent.enabled" = false;
                      "toolkit.telemetry.newProfilePing.enabled" = false;
                      "toolkit.telemetry.reportingpolicy.firstRun" = false;
                      "toolkit.telemetry.shutdownPingSender.enabled" = false;
                      "toolkit.telemetry.unified" = false;
                      "toolkit.telemetry.updatePing.enabled" = false;
                      "experiments.activeExperiment" = false;
                      "experiments.enabled" = false;
                      "experiments.supported" = false;
                      "network.allow-experiments" = false;
                      "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
                      "extensions.pocket.enabled" = false;
                      "extensions.pocket.api" = "";
                      "extensions.pocket.oAuthConsumerKey" = "";
                      "extensions.pocket.showHome" = false;
                      "extensions.pocket.site" = "";
                    };
                  };
                };
                git = {
                  enable = true;
                  package = pkgs.gitAndTools.gitFull; # Install git wiith all the optional extras
                  userName = "KongrooParadox";
                  userEmail = "kongroo.git@proton.me";
                  extraConfig = {
                    core.editor = "nvim";
                    credential.helper = "cache";
                  };
                };
                neovim = {
                  defaultEditor = true;
                  enable = true;
                  vimAlias = true;
                };
                starship = {
                  enable = true;
                  enableZshIntegration = true;
                  enableBashIntegration = true;
                };
                tmux = {
                  enable = true;
                  escapeTime = 0;
                  newSession = true;
                  keyMode = "vi";
                  shell = "${pkgs.zsh}/bin/zsh";
                  historyLimit = 100000;
                  prefix = "C-a";
                  terminal = "screen-256color";
                  clock24 = true;
                  baseIndex = 1;
                  extraConfig = ''
                    set -g status-style 'bg=#333333 fg=#5eacd3'
                    bind -T copy-mode-vi v send-keys -X begin-selection
                    bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
                    bind -r ^ last-window
                    bind -r k select-pane -U
                    bind -r j select-pane -D
                    bind -r h select-pane -L
                    bind -r l select-pane -R
                    bind-key -r f run-shell "tmux-switcher"
                    bind-key -n M-y run-shell "tmux-switcher ~/personal/homelab"
                    bind-key -n M-u run-shell "tmux-switcher ~/nixfiles"
                    bind-key -n M-i run-shell "tmux-switcher ~/personal/kongroo.io"
                    bind-key -n M-o run-shell "tmux-switcher ~/personal/zellij"
                    bind -n Insert next-window
                    bind r source-file ~/.config/tmux/tmux.conf
                  '';
                };
                waybar = {
                  enable = true;
                  settings = {
                    mainBar = {
                      layer = "top";
                      position = "bottom";
                      height= 34; ## Waybar height (to be removed for auto height)
                      spacing= 4; ## Gaps between modules (4px)
                      ## Choose the order of the modules
                      modules-left= ["sway/workspaces" "sway/mode" "sway/scratchpad" "custom/media"];
                      modules-center= ["sway/window"];
                      # modules-right= ["mpd" "idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "keyboard-state" "sway/language" "battery" "battery#bat2" "clock" "tray"];
                      modules-right= ["idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "sway/language" "battery" "clock" "tray"];
                      ## Modules configuration
                      ## sway/workspaces= {
                      ##     disable-scroll= true;
                      ##     all-outputs= true;
                      ##     warp-on-scroll= false;
                      ##     format= "{name}= {icon}";
                      ##     format-icons= {
                      ##         1= "";
                      ##         2= "";
                      ##         3= "";
                      ##         4= "";
                      ##         5= "";
                      ##         urgent= "";
                      ##         focused= "";
                      ##         default= ""
                      ##     }
                      ## };
                      "sway/mode"= {
                        format= "<span style=\"italic\">{}</span>";
                      };
                      "sway/scratchpad"= {
                        format= "{icon} {count}";
                        show-empty= false;
                        format-icons= ["" ""];
                        tooltip= true;
                        tooltip-format= "{app}= {title}";
                      };
                      mpd= {
                        format= "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
                        format-disconnected= "Disconnected ";
                        format-stopped= "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
                        unknown-tag= "N/A";
                        interval= 2;
                        consume-icons= {
                          on= " ";
                        };
                        random-icons= {
                          off= "<span color=\"#f53c3c\"></span> ";
                          on= " ";
                        };
                        repeat-icons= {
                          on= " ";
                        };
                        single-icons= {
                          on= "1 ";
                        };
                        state-icons= {
                          paused= "";
                          playing= "";
                        };
                        tooltip-format= "MPD (connected)";
                        tooltip-format-disconnected= "MPD (disconnected)";
                      };
                      idle_inhibitor= {
                        format= "{icon}";
                        format-icons= {
                          activated= "";
                          deactivated= "";
                        };
                      };
                      tray= {
                        ## icon-size= 21;
                        spacing= 10;
                      };
                      clock= {
                        tooltip-format= "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                        format-alt= "{:%Y-%m-%d}";
                      };
                      cpu= {
                        format= "{usage}% ";
                        tooltip= false;
                      };
                      memory= {
                        format= "{}% ";
                      };
                      temperature= {
                        ## thermal-zone= 2;
                        ## hwmon-path= "/sys/class/hwmon/hwmon2/temp1_input";
                        critical-threshold= 80;
                        ## format-critical= "{temperatureC}°C {icon}";
                        format= "{temperatureC}°C {icon}";
                        format-icons= ["" "" ""];
                      };
                      backlight= {
                        ## device= "acpi_video1";
                        format= "{percent}% {icon}";
                        format-icons= ["" "" "" "" "" "" "" "" ""];
                      };
                      battery= {
                        states= {
                          ## good= 95;
                          warning= 30;
                          critical= 15;
                        };
                        format= "{capacity}% {icon}";
                        format-charging= "{capacity}% ";
                        format-plugged= "{capacity}% ";
                        format-alt= "{time} {icon}";
                        ## format-good= ""; ## An empty format will hide the module
                        ## format-full= "";
                        format-icons= ["" "" "" "" ""];
                      };
                      network= {
                        ## interface= "wlp2*"; ## (Optional) To force the use of this interface
                        format-wifi= "{essid} ({signalStrength}%) ";
                        format-ethernet= "{ipaddr}/{cidr} ";
                        tooltip-format= "{ifname} via {gwaddr} ";
                        format-linked= "{ifname} (No IP) ";
                        format-disconnected= "Disconnected ⚠";
                        format-alt= "{ifname}= {ipaddr}/{cidr}";
                      };
                      pulseaudio= {
                        ## scroll-step= 1; ## %, can be a float
                        format= "{volume}% {icon} {format_source}";
                        format-bluetooth= "{volume}% {icon} {format_source}";
                        format-bluetooth-muted= " {icon} {format_source}";
                        format-muted= " {format_source}";
                        format-source= "{volume}% ";
                        format-source-muted= "";
                        format-icons= {
                          headphone= "";
                          hands-free= "";
                          headset= "";
                          phone= "";
                          portable= "";
                          car= "";
                          default= ["" "" ""];
                        };
                        on-click= "pavucontrol";
                      };
                      "custom/media"= {
                        format= "{icon} {}";
                        return-type= "json";
                        max-length= 40;
                        format-icons= {
                          spotify= "";
                          default= "🎜";
                        };
                        escape= true;
                        exec= "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; ## Script in resources folder;
                      };
                    };
                  };
                };
                zsh = {
                  enable = true;
                  enableAutosuggestions = true;
                  enableCompletion = true;
                  shellAliases = {
                    k         ="kubectl";
                    l         ="ls -lra --color=auto";
                    ls        ="ls --color=auto";
                    ll        ="ls --color=auto -lh";
                    lll       ="ls --color=auto -lh | less";
                    v         ="nvim";
                  };
                  initExtra = ''
                    bindkey -e
                    bindkey -s ^f "tmux-switcher\n"
                    bindkey -s '^[y' "tmux-switcher ~/personal/homelab\n"
                    bindkey -s '^[u' "tmux-switcher ~/nixfiles\n"
                    bindkey -s '^[i' "tmux-switcher ~/personal/kongroo.io\n"
                    bindkey -s '^[o' "tmux-switcher ~/personal/zellij\n"
                    autoload -U +X bashcompinit && bashcompinit
                    complete -F __start_kubectl k
                    complete -o nospace -C $(which terraform) terraform
                  '';
                };
              };
              home.packages = with pkgs; [
                ansible
                ansible-lint
                cargo
                cliphist
                filezilla
                keepassxc
                libreoffice
                mako
                neofetch
                playerctl
                pulseaudio
                rofi
                rustc
                shotman
                starship
                swayidle
                swaylock
                texlive.combined.scheme-full
                wl-clipboard
                xdg-utils
              ];
              editorconfig = {
                enable = true;
                settings = {
                  "*" = {
                    end_of_line = "lf";
                    insert_final_newline = true;
                    trim_trailing_whitespace = true;
                    charset = "utf-8";
                    indent_style = "space";
                    indent_size = 4;
                  };
                  "Makefile" = {
                    indent_style = "tab";
                  };
                  "*.{nix,yaml,yml,tf}" = {
                    indent_size = 2;
                  };
                  "*.md" = {
                    indent_size = 2;
                    trim_trailing_whitespace = false;
                  };
                };
              };
              wayland.windowManager.sway = {
                enable = true;
                wrapperFeatures.gtk = true;
                extraConfig = ''
                exec wl-paste --type image --watch cliphist store
                exec wl-paste --type text --watch cliphist store
                exec_always nm-applet --indicator
                '';
                config = rec {
                  bars = [
                    { command = "waybar"; }
                  ];
                  window = {
                    titlebar = false;
                    hideEdgeBorders = "smart";
                  };
                  floating = {
                    titlebar = false;
                  };
                  terminal = "alacritty";
                  modifier = "Mod4";
                  input."type:keyboard" = {
                    xkb_layout = "us";
                    xkb_variant = ",qwerty,alt-intl";
                    xkb_options = "caps:escape";
                    xkb_numlock = "disabled";
                  };
                  menu = "rofi -show run";
                  keybindings = {
                    "XF86MonBrightnessDown" = "exec light -U 10";
                    "XF86MonBrightnessUp" = "exec light -A 10";
                    "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +1%";
                    "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -1%";
                    "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
                    "${modifier}+1" = "workspace number 1";
                    "${modifier}+2" = "workspace number 2";
                    "${modifier}+3" = "workspace number 3";
                    "${modifier}+4" = "workspace number 4";
                    "${modifier}+5" = "workspace number 5";
                    "${modifier}+6" = "workspace number 6";
                    "${modifier}+7" = "workspace number 7";
                    "${modifier}+8" = "workspace number 8";
                    "${modifier}+9" = "workspace number 9";
                    "${modifier}+0" = "workspace number 10";
                    "${modifier}+Down" = "focus down";
                    "${modifier}+Left" = "focus left";
                    "${modifier}+Right" = "focus right";
                    "${modifier}+Shift+1" = "move container to workspace number 1";
                    "${modifier}+Shift+2" = "move container to workspace number 2";
                    "${modifier}+Shift+3" = "move container to workspace number 3";
                    "${modifier}+Shift+4" = "move container to workspace number 4";
                    "${modifier}+Shift+5" = "move container to workspace number 5";
                    "${modifier}+Shift+6" = "move container to workspace number 6";
                    "${modifier}+Shift+7" = "move container to workspace number 7";
                    "${modifier}+Shift+8" = "move container to workspace number 8";
                    "${modifier}+Shift+9" = "move container to workspace number 9";
                    "${modifier}+Shift+0" = "move container to workspace number 10";
                    "${modifier}+Shift+Down" = "move down";
                    "${modifier}+Shift+Left" = "move left";
                    "${modifier}+Shift+Right" = "move right";
                    "${modifier}+Shift+Up" = "move up";
                    "${modifier}+Shift+c" = "reload";
                    "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
                    "${modifier}+Shift+h" = "move left";
                    "${modifier}+Shift+j" = "move down";
                    "${modifier}+Shift+k" = "move up";
                    "${modifier}+Shift+l" = "move right";
                    "${modifier}+Shift+minus" = "move scratchpad";
                    "${modifier}+Shift+q" = "kill";
                    "${modifier}+Shift+space" = "floating toggle";
                    "${modifier}+Shift+s" = "exec shotman -c region";
                    "${modifier}+Up" = "focus up";
                    "${modifier}+a" = "focus parent";
                    "${modifier}+b" = "splith";
                    "${modifier}+d" = "exec rofi -show run";
                    "${modifier}+e" = "layout toggle split";
                    "${modifier}+f" = "fullscreen toggle";
                    "${modifier}+h" = "focus left";
                    "${modifier}+j" = "focus down";
                    "${modifier}+k" = "focus up";
                    "${modifier}+l" = "focus right";
                    "${modifier}+minus" = "scratchpad show";
                    "${modifier}+r" = "mode resize";
                    "${modifier}+s" = "layout stacking";
                    "${modifier}+t" = "exec alacritty";
                    "${modifier}+space" = "focus mode_toggle";
                    "${modifier}+v" = "exec cliphist list | rofi -dmenu | cliphist decode | wl-copy";
                    # "${modifier}+v" = "splitv";
                    "${modifier}+w" = "layout tabbed";
                  };
                  output = {
                    eDP-1 = {
                      scale = "1.3";
                      mode = "1920x1200@60Hz";
                      pos = "0 0";
                    };
                    DP-1 = {
                      scale = "1";
                      mode = "1920x1200@60Hz";
                      pos = "1477 -377";
                    };
                    HDMI-A-1 = {
                      scale = "1";
                      mode = "1920x1080@60Hz";
                      pos = "3397 -346";
                    };
                  };
                  workspaceOutputAssign = [
                  { workspace ="1"; output = "eDP-1"; }
                  { workspace ="2"; output = "HDMI-A-1"; }
                  { workspace ="3"; output = "DP-1"; }
                  ];
                };
              };
              home.stateVersion = "23.11";
            };
          };
        }
      ];
    };
  };
}
