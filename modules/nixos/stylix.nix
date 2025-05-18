{ config, inputs, lib, pkgs, ...}:
let
  isUnstable = lib.versions.majorMinor lib.version >= "25.05";
  nixCfg = if isUnstable then {
    monoPkg = pkgs.nerd-fonts.jetbrains-mono;
    stylixModule = [ inputs.stylix-unstable.nixosModules.stylix ];
  }
  else {
    monoPkg = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
    stylixModule = [ inputs.stylix.nixosModules.stylix ];
  };
  inherit (nixCfg) monoPkg stylixModule;
in
{
  imports = stylixModule;

  config = lib.mkIf (config.desktop.enable && (config.desktop.environment == "hyprland")) {
    stylix = {
      enable = true;
      autoEnable = true;
      image = ../../wallpapers/dark-nebula.jpg;

      base16Scheme = {
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
      polarity = "dark";
      opacity.terminal = 0.8;
      cursor.package = pkgs.bibata-cursors;
      cursor.name = "Bibata-Modern-Ice";
      cursor.size = 24;
      fonts = {
        monospace = {
          package = monoPkg;
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
  };
}
