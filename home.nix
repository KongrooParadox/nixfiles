{ pkgs, ... }:

{
  home.username = "robot";
  home.homeDirectory = "/home/robot";

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
    texlive.combined.scheme-full
    wl-clipboard
    xdg-utils
  ];

  home.file = {
    "libvirt.conf" = {
      source = ./dotfiles/libvirt;
      target = ".config/libvirt";
    };
    "nvim" = {
      source = ./dotfiles/nvim;
      target = ".config/nvim";
      recursive = true;
    };
    "scripts" = {
      source = ./dotfiles/bin;
      target = ".local/bin";
    };
    ".ssh/config" = {
      source = ./dotfiles/ssh/config;
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
    chromium.enable = true;
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
      package = pkgs.gitAndTools.gitFull;
      userName = "Guillaume Nanty";
      userEmail = "7790572+KongrooParadox@users.noreply.github.com";
      signing = {
        signByDefault = true;
        gpgPath = "/run/current-system/sw/bin/gpg";
        key = "E1FFAC5C39F79113";
      };
      lfs.enable = true;
      extraConfig = {
        core = {
          editor = "nvim";
          autocrlf = false;
          whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
          excludesfile = "~/.gitignore";
        };
        help.autocorrect = 20;
        init.defaultBranch = "main";
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
    zsh = {
      enable = true;
      autosuggestion.enable = true;
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
        path+=('/home/robot/go/bin')
        '';
    };
  };

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

  home.stateVersion = "23.11";
# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
