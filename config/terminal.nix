{ pkgs, lib, ... }:
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
}
