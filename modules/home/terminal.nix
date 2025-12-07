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
      settings = {
        # custom module for jj status
        custom = {
          git_branch = {
            when = "! jj --ignore-working-copy root";
            command = "starship module git_branch";
            description = "Only show git_branch if we're not in a jj repo";
            style = "";
            ignore_timeout = true;
          };
          git_commit = {
            when = "! jj --ignore-working-copy root";
            command = "starship module git_commit";
            style = "";
            description = "Only show git_commit if we're not in a jj repo";
            ignore_timeout = true;
          };
          git_metrics = {
            when = "! jj --ignore-working-copy root";
            command = "starship module git_metrics";
            description = "Only show git_metrics if we're not in a jj repo";
            style = "";
            ignore_timeout = true;
          };
          git_status = {
            when = "! jj --ignore-working-copy root";
            command = "starship module git_status";
            style = ""; # This disables the default "(bold green)" style
            description = "Only show git_status if we're not in a jj repo";
            ignore_timeout = true;
          };
          jj = {
            description = "The current jj status";
            when = "jj --ignore-working-copy root";
            symbol = "🥋 ";
            command = ''
              jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                separate(" ",
                  change_id.shortest(4),
                  bookmarks,
                  "|",
                  concat(
                    if(conflict, "💥"),
                    if(divergent, "🚧"),
                    if(hidden, "👻"),
                    if(immutable, "🔒"),
                  ),
                  raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                  raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                    truncate_end(29, description.first_line(), "…"),
                    "(no description set)",
                  ) ++ raw_escape_sequence("\x1b[0m"),
                )
              '
            '';
            ignore_timeout = true;
          };
        };
        git_branch.disabled = true;
        git_commit.disabled = true;
        git_metrics.disabled = true;
        git_status.disabled = true;
      };
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
      initContent = ''
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
      '';
    };
  };
  home.packages = with pkgs; [
    tmux
  ];
}
