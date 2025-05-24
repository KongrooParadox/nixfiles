{
  config,
  pkgs,
  ...
}:
{
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
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
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
      aggressiveResize = true;
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_window_current_text " #W"
            set -g @catppuccin_window_text " #W"
            set -g status-right-length 100
            set -g status-right "#{E:@catppuccin_status_host}"
            set -agF status-right "#{E:@catppuccin_status_cpu}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            set -ag status-right "#{E:@catppuccin_status_date_time}"
            set -agF status-right "#{E:@catppuccin_status_battery}"
          '';
        }
        tmuxPlugins.cpu
        tmuxPlugins.battery
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
      ];
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g status-left ""
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
        # Focus events enabled for terminals that support them
        set -g focus-events on
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
        bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
        bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
        bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
        bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
            "bind-key -n 'M-\\' if-shell \"$is_vim\" 'send-keys M-\\\\'  'select-pane -l'"
        bind-key -T copy-mode-vi 'M-h' select-pane -L
        bind-key -T copy-mode-vi 'M-j' select-pane -D
        bind-key -T copy-mode-vi 'M-k' select-pane -U
        bind-key -T copy-mode-vi 'M-l' select-pane -R
        bind-key -T copy-mode-vi 'M-\' select-pane -l
      '';
    };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      shellAliases = {
        k = "kubectl";
        l = "ls -lra --color=auto";
        ls = "ls --color=auto";
        ll = "ls --color=auto -lh";
        lll = "ls --color=auto -lh | less";
        v = "nvim";
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
        path+=('${config.home.homeDirectory}/go/bin')
        path+=('${config.home.homeDirectory}/.local/bin')
        export ANTHROPIC_API_KEY="$(cat ${config.sops.secrets.anthropic-api-key.path})"
      '';
    };
  };
}
