{ config, lib, pkgs, stateVersion, ... }:
let
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable desktop-specific config";
    };
  };

  config = lib.mkIf cfg.enable {
    system.stateVersion = stateVersion;

    environment = {
      sessionVariables.GSK_RENDERER = "gl"; # Fix GTK apps : https://github.com/NixOS/nixpkgs/issues/353990
      systemPackages = with pkgs; [
        adwaita-icon-theme
        android-tools
        buildah
        calibre
        deluge-gtk
        #discord #broken for aarch64
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
        krita
        kubectl
        kubernetes-helm
        libimobiledevice # usb drivers for apple mobile devices
        mesa
        mesa.drivers
        moonlight-qt
        networkmanagerapplet
        nixos-anywhere
        nodejs_22
        parsec-bin
        pavucontrol
        peek
        pkg-config
        podman
        protonmail-bridge
        protonvpn-gui
        python3
        remmina
        samba
        screenkey
        swaynotificationcenter
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

    # Thunar
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images

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
