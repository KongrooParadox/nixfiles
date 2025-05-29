{
  pkgs,
  lib,
  system,
  ...
}:
let
  firacodePkg =
    if lib.versions.majorMinor lib.version >= "25.05" then
      pkgs.nerd-fonts.fira-code
    else
      pkgs.fira-code-nerdfont;
  isLinux = lib.strings.hasSuffix "linux" system;
in
{
  imports = [ ] ++ (lib.optional isLinux ../nixos/fonts.nix);

  fonts = {
    packages = with pkgs; [
      font-awesome
      twitter-color-emoji
      firacodePkg
    ];
  };
}
