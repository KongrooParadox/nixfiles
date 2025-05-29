{ }:
{
  fonts = {
    enableDefaultPackages = true;
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
