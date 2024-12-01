{pkgs, inputs, ...}:

let
  monospacePackage = if builtins.substring 0 5 inputs.nixpkgs.lib.version >= "25.05"
    then pkgs.nerd-fonts.jetbrains-mono
    else pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };

in
{
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../wallpapers/dark-nebula.jpg;

    base16Scheme = {
      # # Catppucin Mocha
      # base00 = "1e1e2e";
      # base01 = "181825";
      # base02 = "313244";
      # base03 = "45475a";
      # base04 = "585b70";
      # base05 = "cdd6f4";
      # base06 = "f5e0dc";
      # base07 = "b4befe";
      # base08 = "f38ba8";
      # base09 = "fab387";
      # base0A = "f9e2af";
      # base0B = "a6e3a1";
      # base0C = "94e2d5";
      # base0D = "89b4fa";
      # base0E = "cba6f7";
      # base0F = "f2cdcd";
      # Nord
      base00 = "2E3440";
      base01 = "3B4252";
      base02 = "434C5E";
      base03 = "4C566A";
      base04 = "D8DEE9";
      base05 = "E5E9F0";
      base06 = "ECEFF4";
      base07 = "8FBCBB";
      base08 = "BF616A";
      base09 = "D08770";
      base0A = "EBCB8B";
      base0B = "A3BE8C";
      base0C = "88C0D0";
      base0D = "81A1C1";
      base0E = "B48EAD";
      base0F = "5E81AC";
    };
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      monospace = {
        package = monospacePackage;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
