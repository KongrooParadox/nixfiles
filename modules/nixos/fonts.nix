{ config, ... }:
{
  fonts = {
    enableDefaultPackages = config.kp.desktop.enable;
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [
          "Font Awesome 5 Free"
          "Noto Color Emoji"
        ];
        monospace = [
          "SFMono Nerd Font"
          "SF Mono"
        ];
        serif = [ "New York Medium" ];
        sansSerif = [ "SF Pro Text" ];
      };
    };
  };
}
