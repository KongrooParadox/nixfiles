{ config, desktop, lib, ... }:

{
  config = lib.mkIf desktop.enable {
    programs.hyprlock.enable = true;
  };
}
