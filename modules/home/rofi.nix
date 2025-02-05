{ pkgs, config, desktop, lib, ... }:

{
  config = lib.mkIf desktop.enable {
    stylix.targets.rofi.enable = false;
    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        extraConfig = {
          modi = "drun,filebrowser,run";
          show-icons = true;
          icon-theme = "Papirus";
          location = 0;
          font = "JetBrainsMono Nerd Font Mono 12";
          drun-display-format = "{icon} {name}";
          display-drun = " Apps";
          display-run = " Run";
          display-filebrowser = " File";
        };
        theme =
          {
            "*" = {
              bg = lib.mkForce "#${config.stylix.base16Scheme.base00}";
              bg-alt = lib.mkForce "#${config.stylix.base16Scheme.base09}";
              foreground = lib.mkForce "#${config.stylix.base16Scheme.base01}";
              selected = lib.mkForce "#${config.stylix.base16Scheme.base08}";
              active = lib.mkForce "#${config.stylix.base16Scheme.base0B}";
              text-selected = lib.mkForce "#${config.stylix.base16Scheme.base00}";
              text-color = lib.mkForce "#${config.stylix.base16Scheme.base05}";
              border-color = lib.mkForce "#${config.stylix.base16Scheme.base0F}";
              urgent = lib.mkForce "#${config.stylix.base16Scheme.base0E}";
            };
            "window" = {
              width = lib.mkForce "50%";
              transparency = "real";
              orientation = lib.mkForce "vertical";
              cursor = lib.mkForce "default";
              spacing = lib.mkForce "0px";
              border = lib.mkForce "2px";
              border-color = "@border-color";
              border-radius = lib.mkForce "20px";
              background-color = lib.mkForce "@bg";
            };
            "mainbox" = {
              padding = lib.mkForce "15px";
              enabled = true;
              orientation = lib.mkForce "vertical";
              children = map lib.mkForce [
                "inputbar"
                "listbox"
              ];
              background-color = lib.mkForce "transparent";
            };
            "inputbar" = {
              enabled = true;
              padding = lib.mkForce "10px 10px 200px 10px";
              margin = lib.mkForce "10px";
              background-color = lib.mkForce "transparent";
              border-radius = "25px";
              orientation = lib.mkForce "horizontal";
              children = map lib.mkForce [
                "entry"
                "dummy"
                "mode-switcher"
              ];
              background-image = lib.mkForce ''url("../../wallpapers/bright-milky-way.jpg", width)'';
            };
            "entry" = {
              enabled = true;
              expand = false;
              width = lib.mkForce "20%";
              padding = lib.mkForce "10px";
              border-radius = lib.mkForce "12px";
              background-color = lib.mkForce "@selected";
              text-color = lib.mkForce "@text-selected";
              cursor = lib.mkForce "text";
              placeholder = "🖥️ Search ";
              placeholder-color = lib.mkForce "inherit";
            };
            "listbox" = {
              spacing = lib.mkForce "10px";
              padding = lib.mkForce "10px";
              background-color = lib.mkForce "transparent";
              orientation = lib.mkForce "vertical";
              children = map lib.mkForce [
                "message"
                "listview"
              ];
            };
            "listview" = {
              enabled = true;
              columns = 2;
              lines = 6;
              cycle = true;
              dynamic = true;
              scrollbar = false;
              layout = lib.mkForce "vertical";
              reverse = false;
              fixed-height = false;
              fixed-columns = true;
              spacing = lib.mkForce "10px";
              background-color = lib.mkForce "transparent";
              border = lib.mkForce "0px";
            };
            "dummy" = {
              expand = true;
              background-color = lib.mkForce "transparent";
            };
            "mode-switcher" = {
              enabled = true;
              spacing = lib.mkForce "10px";
              background-color = lib.mkForce "transparent";
            };
            "button" = {
              width = lib.mkForce "5%";
              padding = lib.mkForce "12px";
              border-radius = lib.mkForce "12px";
              background-color = lib.mkForce "@text-selected";
              text-color = lib.mkForce "@text-color";
              cursor = lib.mkForce "pointer";
            };
            "button selected" = {
              background-color = lib.mkForce "@selected";
              text-color = lib.mkForce "@text-selected";
            };
            "scrollbar" = {
              width = lib.mkForce "4px";
              border = 0;
              handle-color = lib.mkForce "@border-color";
              handle-width = lib.mkForce "8px";
              padding = 0;
            };
            "element" = {
              enabled = true;
              spacing = lib.mkForce "10px";
              padding = lib.mkForce "10px";
              border-radius = lib.mkForce "12px";
              background-color = lib.mkForce "transparent";
              cursor = lib.mkForce "pointer";
            };
            "element normal.normal" = {
              background-color = lib.mkForce "inherit";
              text-color = lib.mkForce "inherit";
            };
            "element normal.urgent" = {
              background-color = lib.mkForce "@urgent";
              text-color = lib.mkForce "@foreground";
            };
            "element normal.active" = {
              background-color = lib.mkForce "@active";
              text-color = lib.mkForce "@foreground";
            };
            "element selected.normal" = {
              background-color = lib.mkForce "@selected";
              text-color = lib.mkForce "@text-selected";
            };
            "element selected.urgent" = {
              background-color = lib.mkForce "@urgent";
              text-color = lib.mkForce "@text-selected";
            };
            "element selected.active" = {
              background-color = lib.mkForce "@urgent";
              text-color = lib.mkForce "@text-selected";
            };
            "element alternate.normal" = {
              background-color = lib.mkForce "transparent";
              text-color = lib.mkForce "inherit";
            };
            "element alternate.urgent" = {
              background-color = lib.mkForce "transparent";
              text-color = lib.mkForce "inherit";
            };
            "element alternate.active" = {
              background-color = lib.mkForce "transparent";
              text-color = lib.mkForce "inherit";
            };
            "element-icon" = {
              background-color = lib.mkForce "transparent";
              text-color = lib.mkForce "inherit";
              size = lib.mkForce "36px";
              cursor = lib.mkForce "inherit";
            };
            "element-text" = {
              background-color = lib.mkForce "transparent";
              font = "JetBrainsMono Nerd Font Mono 12";
              text-color = lib.mkForce "inherit";
              cursor = lib.mkForce "inherit";
              vertical-align = lib.mkForce "0.5";
              horizontal-align = lib.mkForce "0.0";
            };
            "message" = {
              background-color = lib.mkForce "transparent";
              border = lib.mkForce "0px";
            };
            "textbox" = {
              padding = lib.mkForce "12px";
              border-radius = lib.mkForce "10px";
              background-color = lib.mkForce "@bg-alt";
              text-color = lib.mkForce "@bg";
              vertical-align = lib.mkForce "0.5";
              horizontal-align = lib.mkForce "0.0";
            };
            "error-message" = {
              padding = lib.mkForce "12px";
              border-radius = lib.mkForce "20px";
              background-color = lib.mkForce "@bg-alt";
              text-color = lib.mkForce "@bg";
            };
          };
      };
    };

    home.file.".config/rofi/config-long.rasi".text = ''
      @import "~/.config/rofi/config.rasi"
      window {
        width: 50%;
      }
      entry {
        placeholder: "🔎 Search       ";
      }
      listview {
        columns: 1;
        lines: 8;
        scrollbar: true;
      }
    '';
  };
}
