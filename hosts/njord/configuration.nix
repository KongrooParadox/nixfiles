{ pkgs, config, inputs, ... }:

{
  nixpkgs.config.allowUnsupportedSystem = true;
  nix = {
    # sets NIX_PATH to flake input for nixd
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "robot" ];
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        extraEntries."debian.conf" = ''
          title Debian
          efi   /efi/debian/shimx64.efi
        '';
      };
    };
    extraModulePackages = with config.boot.kernelPackages; [
      evdi
    ];
    supportedFilesystems = [ "ntfs" ];
  };

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimize storage
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [
        "wlp1s0f0"
        "virbr1"
      ];
    };
    networkmanager.enable = true;
    hostName = "njord";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_COLLATE = "en_GB.UTF-8";
      LC_CTYPE = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MESSAGES = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users")
              && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions"
              )
            )
          {
            return polkit.Result.YES;
          }
        })
      '';
    };

  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };


  # audio
  security.rtkit.enable = true;

  services = {
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          user = "robot";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
        };
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    blueman.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [ "displaylink" "modesetting" ];
      xkb = {
        layout = "us";
        variant = "";
      };
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };

  programs.light.enable = true;
  programs.zsh.enable = true;
  users.users.robot = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Robot";
    extraGroups = [ "networkmanager" "wheel" "video" "libvirtd" ];
    openssh.authorizedKeys.keys = (import ../../modules/ssh.nix).keys;
  };

  security.sudo.extraRules= [
    {  users = [ "robot" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      twitter-color-emoji
      nerd-fonts.fira-code
    ];
    fontconfig.enable = true;
    fontconfig.defaultFonts = {
      emoji = [ "Font Awesome 5 Free" "Noto Color Emoji" ];
      monospace = [ "SFMono Nerd Font" "SF Mono" ];
      serif = [ "New York Medium" ];
      sansSerif = [ "SF Pro Text" ];
    };
  };

  environment = {
    sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card0";
    };
    variables = {
      LANG = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
    };
    localBinInPath = true;
  };

  environment.systemPackages = with pkgs; [
    acpi
    age
    teams-for-linux
    android-tools
    bat
    buildah
    calibre
    cdrkit
    cmake
    curl
    deluge-gtk
    direnv
    #discord #broken for aarch64
    displaylink
    dnsutils
    element-desktop
    evolution
    fd
    fzf
    gcc
    gimp#-with-plugins # broken for aarch64
    adwaita-icon-theme
    gnumake
    gnupg
    go
    helm-ls
    helmfile
    htop
    hugo
    hyprpicker
    inkscape
    ipcalc
    iptables
    jq
    krita
    kubectl
    kubernetes-helm
    lftp
    lsb-release
    mesa
    mesa.drivers
    moonlight-qt
    nettools
    networkmanagerapplet
    nmap
    nixos-anywhere
    nodejs_22
    openvpn
    parsec-bin
    pavucontrol
    peek
    pkg-config
    podman
    protonmail-bridge
    protonvpn-gui
    python3
    remmina
    ripgrep
    rsync
    samba
    screenkey
    sops
    spotify
    subversion
    sudo
    ssh-to-age
    swaynotificationcenter
    tcpdump
    terraform-ls
    traceroute
    transmission_4
    tree
    unzip
    usbutils
    # vagrant # disabled until fix is released to nixpkgs unstable
    virt-manager
    virtualenv
    vlc
    wget
    wireguard-tools
    xorg.xrandr
    xournalpp
    yad
    yq
    # usb drivers for apple mobile devices
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
  ];

  services.usbmuxd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 7200;
      max-cache-ttl = 43200;
    };
  };

  # Thunar
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable emulation for x86
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  # Steam currently not working on aarch64
  #  programs.steam = {
  #    enable = true;
  #    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  #  };

  system.stateVersion = "24.11";

}
