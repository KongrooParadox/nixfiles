{
  config,
  inputs,
  lib,
  pkgs,
  stateVersion,
  users,
  usesDisplaylink,
  self,
  ...
}:
let
  cfg = config.kp.desktop;
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
    # Needed for monitor brightness controls
    hardware.i2c.enable = true;

    environment = {
      sessionVariables.GSK_RENDERER = "gl"; # Fix GTK apps : https://github.com/NixOS/nixpkgs/issues/353990
      systemPackages =
        with pkgs;
        [
          adwaita-icon-theme
          android-tools
          bitwarden-cli
          cmake
          ddcutil
          deluge-gtk
          element-desktop
          gcc
          gnumake
          evolution
          gimp
          gnupg
          hugo
          hyprpicker
          inkscape
          kooha
          mesa
          mesa-demos
          moonlight-qt
          networkmanagerapplet
          nixos-anywhere
          # No TTS: speechSupport drops piper/speechd, espeak-ng (always linked) drops ~0.6 GiB of mbrola voices
          (calibre.override {
            speechSupport = false;
            espeak-ng = espeak-ng.override { mbrolaSupport = false; };
          })
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
          teams-for-linux
          transmission_4
          usbutils
          vesktop
          virt-manager
          virtualenv
          vulkan-tools
          wireguard-tools
          xournalpp
          yad
          zapzap
        ]
        ++ lib.optionals config.kp.apps.krita.enable [ krita ]
        ++ lib.optionals usesDisplaylink [
          displaylink
        ];
    };

    nixpkgs.overlays = lib.mkIf usesDisplaylink [
      self.overlays.ddcutil-evdi
    ];

    # Needed for monitor brightness controls
    users.users = builtins.listToAttrs (
      map (user: {
        name = user;
        value.extraGroups = [ "i2c" ];
      }) users
    );

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

    # Only for screen readers and browser text-to-speech; drags in the mbrola voices.
    # GNOME keeps it for its accessibility stack.
    services.speechd.enable = lib.mkIf (cfg.environment != "gnome") false;

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
