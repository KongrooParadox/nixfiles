{
  config,
  inputs,
  lib,
  pkgs,
  stateVersion,
  ...
}:
let
  cfg = config.kp.desktop;
  nixpkgs-stable = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.kp.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable desktop-specific config";
    };
    environment = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "plasma"
        "gnome"
      ];
      default = "hyprland";
      description = lib.mdDoc "Which Desktop Environment to install (hyprland, plasma or gnome)";
    };
  };

  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./plasma.nix
  ];

  config = lib.mkIf cfg.enable {
    system.stateVersion = stateVersion;

    environment = {
      sessionVariables.GSK_RENDERER = "gl"; # Fix GTK apps : https://github.com/NixOS/nixpkgs/issues/353990
      systemPackages =
        with pkgs;
        [
          adwaita-icon-theme
          android-tools
          nixpkgs-stable.calibre
          deluge-gtk
          displaylink
          element-desktop
          evolution
          gimp
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
          kubectx
          kubernetes-helm
          k9s
          libimobiledevice # usb drivers for apple mobile devices
          mesa
          mesa-demos
          moonlight-qt
          networkmanagerapplet
          nixos-anywhere
          nodejs_22
          parsec-bin
          pavucontrol
          pkg-config
          protonmail-bridge
          # protonvpn-gui # python3.13-proton-core-0.4.0 build KO
          python3
          remmina
          samba
          screenkey
          talosctl
          teams-for-linux
          transmission_4
          usbutils
          virt-manager
          vlc
          vulkan-tools
          wireguard-tools
          xournalpp
        ]
        ++ lib.optionals (config.nixpkgs.hostPlatform.system != "aarch64-linux") [
          discord
        ];
    };

    # Apple usb
    services.usbmuxd.enable = true;

    services.xserver = {
      enable = true;
      videoDrivers = [
        "displaylink"
        "modesetting"
      ];
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
