{
  config,
  inputs,
  lib,
  pkgs,
  isLinux,
  isUnstable,
  ...
}:
let
  cfg = config.kp.stylix;
  nixCfg = {
    monoPkg = pkgs.nerd-fonts.jetbrains-mono;
    stylixModule =
      if isUnstable then
        if isLinux then
          [ inputs.stylix-unstable.nixosModules.stylix ]
        else
          [ inputs.stylix-unstable.darwinModules.stylix ]
      else if isLinux then
        [ inputs.stylix.nixosModules.stylix ]
      else
        [ inputs.stylix.darwinModules.stylix ];
  };
  inherit (nixCfg) monoPkg stylixModule;
in
{
  options.kp.stylix = {
    enable = lib.mkEnableOption "stylix theming";
  };

  imports = stylixModule ++ (lib.optional isLinux ../nixos/stylix.nix);

  config = lib.mkIf (cfg.enable) {
    stylix = {
      enable = true;
      autoEnable = true;
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
