{ pkgs, lib, ... }:
let
  firacodePkg = if lib.versions.majorMinor lib.version == "25.05"
    then pkgs.nerd-fonts.fira-code
    else pkgs.fira-code-nerdfont;
in
{
  fonts = {
    packages = with pkgs; [
      font-awesome
      twitter-color-emoji
      firacodePkg
    ];
  };
}
