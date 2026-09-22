{
  config,
  inputs,
  lib,
  pkgs,
  stateVersion,
  usesDisplaylink,
  ...
}:
let
  cfg = config.kp.desktop;
  nixpkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.kp.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable desktop-specific config";
    };
    environment = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "plasma"
        "gnome"
      ];
      default = "hyprland";
      description = "Which Desktop Environment to install (hyprland, plasma or gnome)";
    };
    stylix = lib.mkOption {
      type = lib.types.bool;
      default = (
        cfg.enable
        && builtins.elem config.kp.desktop.environment [
          "hyprland"
          "macos"
        ]
      );
      description = "Whether to enable Stylix theming";
    };
  };

  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./plasma.nix
  ]
  ++ lib.optionals usesDisplaylink [
    "${inputs.nixpkgs-unstable}/nixos/modules/hardware/video/displaylink.nix"
  ];

  config = lib.mkIf cfg.enable {
    kp.networking.networkmanager = {
      enable = true;
      wireless = true;
    };
    system.stateVersion = stateVersion;

    hardware.graphics.package = pkgs.mesa;

    environment = {
      sessionVariables.GSK_RENDERER = "gl"; # Fix GTK apps : https://github.com/NixOS/nixpkgs/issues/353990
      systemPackages =
        with pkgs;
        [
          adwaita-icon-theme
          android-tools
          deluge-gtk
          element-desktop
          evolution
          gimp
          gnupg
          go
          helmfile
          hugo
          hyprpicker
          inkscape
          k9s
          kooha
          krita
          kubectl
          kubectx
          kubernetes-helm
          mesa
          mesa-demos
          moonlight-qt
          networkmanagerapplet
          nixos-anywhere
          nixpkgs-stable.calibre
          nodejs_22
          parsec-bin
          pavucontrol
          pkg-config
          proton-vpn
          protonmail-bridge
          python3
          remmina
          samba
          screenkey
          talosctl
          teams-for-linux
          transmission_4
          usbutils
          vesktop
          virt-manager
          vlc
          vulkan-tools
          wireguard-tools
          xournalpp
          zapzap
        ]
        ++ lib.optionals usesDisplaylink [
          displaylink
        ];
    };

    # Printer config
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      printing = {
        enable = true;
        drivers = with pkgs; [
          cups-filters
          cups-browsed
        ];
      };
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
