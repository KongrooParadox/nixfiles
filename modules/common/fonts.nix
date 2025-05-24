{
  config,
  pkgs,
  lib,
  ...
}:
let
  firacodePkg = if lib.versions.majorMinor lib.version >= "25.05"
    then pkgs.nerd-fonts.fira-code
    else pkgs.fira-code-nerdfont;
  isLinux = lib.strings.hasSuffix "linux" config.nixpkgs.system;
in
{
  fonts = {
    enableDefaultPackages =  lib.mkIf isLinux true;
    packages = with pkgs; [
      font-awesome
      twitter-color-emoji
      firacodePkg
    ];
    fontconfig = lib.mkIf isLinux {
      enable = true;
      defaultFonts = {
        emoji = [ "Font Awesome 5 Free" "Noto Color Emoji" ];
        monospace = [ "SFMono Nerd Font" "SF Mono" ];
        serif = [ "New York Medium" ];
        sansSerif = [ "SF Pro Text" ];
      };
    };
  };
}
