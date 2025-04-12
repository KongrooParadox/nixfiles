{ config, inputs, lib, pkgs, stateVersion, ... }:
let
  cfg = config.desktop;
  nixpkgs-stable = inputs.nixpkgs.legacyPackages.${pkgs.system};
in
{
  options.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable desktop-specific config";
    };
    environment = lib.mkOption {
      type = lib.types.enum [ "hyprland" "plasma" "gnome" ];
      default = "hyprland";
      description = lib.mdDoc "Which Desktop Environment to install (hyprland, plasma or gnome)";
    };
  };

  imports = [ ./gnome.nix ./hyprland.nix ./plasma.nix ];

  config = lib.mkIf cfg.enable {
    system.stateVersion = stateVersion;

    environment = {
      sessionVariables.GSK_RENDERER = "gl"; # Fix GTK apps : https://github.com/NixOS/nixpkgs/issues/353990
      systemPackages = with pkgs; [
        adwaita-icon-theme
        android-tools
        nixpkgs-stable.calibre
        deluge-gtk
        # discord #broken for aarch64
        displaylink
        element-desktop
        evolution
        gimp#-with-plugins # broken for aarch64
        gnupg
        go
        helmfile
        hugo
        hyprpicker
        ifuse # optional, to mount using 'ifuse'
        inkscape
        kooha
        krita
        kubectl
        kubernetes-helm
        libimobiledevice # usb drivers for apple mobile devices
        mesa
        moonlight-qt
        networkmanagerapplet
        nixos-anywhere
        nodejs_22
        parsec-bin
        pavucontrol
        pkg-config
        protonmail-bridge
        protonvpn-gui
        python3
        remmina
        samba
        screenkey
        teams-for-linux
        transmission_4
        usbutils
        # vagrant # disabled until fix is released to nixpkgs unstable
        virt-manager
        vlc
        wireguard-tools
        xournalpp
      ];
    };

    # Apple usb
    services.usbmuxd.enable = true;

    services.xserver = {
      enable = true;
      videoDrivers = [ "displaylink" "modesetting" ];
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal
      ];
    };
  };
}
