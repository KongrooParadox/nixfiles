# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "robot" ];
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
    options = "--delete-older-than 1m";
  };

  # Optimize storage
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  networking = {
    networkmanager.enable = true;
    hostName = "baldur-nix";
    wg-quick.interfaces = {
      wg-home = {
        autostart = false;
        privateKeyFile = config.sops.secrets."wireguard/home".path;
        address = ["192.168.27.66/32"];
        dns = ["212.27.38.253"];
        mtu = 1360;
        peers = [
          {
            publicKey = "0EzF1p0gwkm8mxMM8stqDwpsehl+HcuyFLgmlwbC1xU=";
            endpoint = "88.174.237.209:56273";
            allowedIPs = ["0.0.0.0/0" "192.168.27.64/27" "192.168.1.0/24" "::/0"];
            persistentKeepalive = 25;
          }
        ];
      };
      wg-casa-anita = {
        autostart = false;
        privateKeyFile = config.sops.secrets."wireguard/casa-anita".path;
        address = ["192.168.27.65/32"];
        dns = ["212.27.38.253"];
        mtu = 1360;
        peers = [
          {
            publicKey = "aKfJbVgXBM+fJtbxNVmVYImtMwXQAFwlYNh4d6zo6TQ=";
            endpoint = "91.171.231.205:33436";
            allowedIPs = ["0.0.0.0/0" "192.168.27.64/27" "192.168.1.0/24" "::/0"];
            persistentKeepalive = 25;
          }
        ];
      };
    };
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

  security.polkit.enable = true;
  hardware.graphics.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # audio
  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    blueman.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [ "displaylink" "modesetting" ];
    };
  };

  # KDE Plasma
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    oxygen
  ];

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.light.enable = true;
  programs.zsh.enable = true;
  users.users.robot = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Robot";
    extraGroups = [ "networkmanager" "wheel" "video" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0cG9xQTQGWr39RvqzGojsyjpiMJiFSS6jSWAt3I1EPouxmcITnxIs1C2642RFzC7dfNAZVNUKp6p9Y/7cjXyri0XvLHxbFQ/51WGGpZ+7GgMPaNZXVPFwt3O4h+UcO0VC8KCRSVRKT+XCOh/6HLmDwonWr2S8SMAdQwflATZIwpCTlqv5l6ypyk+NjzBazl3OXNOWmuL8vriwzwYA6Fo6a5R5zwnyY2L/Oh84lg5MVeW2efXtAKWEQY7VyBlrLHsFkXRb8i3p2jbnP2njgLdZhZMhcECVCqgRxyDjtoc1CsgCRsfW6kvXrowIxJruNaAgbD2mq8ctNNo8TMxZUAP9aimoO+7ttTMSCnwvDSyBzPMqtJmqjzSNkLtT27F43hM8JguoW3nnY0um7eYR6Cp/CAMOUAV0nF+TEYlOBVSYws+k3RGViENL93R0PPKwJKd5MG0I4Yaga+/PnemezKekiN/+wgmvAfYvlnTjxYd6ccv3VWdO+uI3zNWGxi2fAkfZ+I5BMwdmbL5fAenKJMGzQXcRf+wrvcdgsdkGlxbFiWE9ehUBI3A0bbpP+DgVUTlLYqavPhumj7cGIcdhvDctFskn98MBr/ujJltpf3ZzVSZD+2507cszzD+W+ZpBU57no6cpG8OIqUuAiDeNSgjAwzh+dTzg4Vh+Bnq4riVYZQ=="
    ];
  };

  # Allow swaylock to unlock the computer for us
  security.pam.services.swaylock = {
    text = "auth include login";
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
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
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
    variables = {
      LANG = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
    };
    localBinInPath = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    age
    android-tools
    bat
    buildah
    calibre
    cdrkit
    cmake
    curl
    deluge-gtk
    direnv
    discord
    displaylink
    dnsutils
    evolution
    fd
    fzf
    gcc
    gimp-with-plugins
    adwaita-icon-theme
    gnumake
    gnupg
    go
    helm-ls
    htop
    hugo
    inkscape
    ipcalc
    iptables
    jq
    krita
    kubectl
    kubernetes-helm
    lftp
    moonlight-qt
    nettools
    networkmanagerapplet
    nmap
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
    python311Packages.pip
    remmina
    ripgrep
    rsync
    samba
    screenkey
    sops
    spotify
    subversion
    sudo
    tcpdump
    terraform
    terraform-ls
    traceroute
    transmission_4
    tree
    unzip
    usbutils
    vagrant
    virt-manager
    virtualenv
    vlc
    wget
    wireguard-tools
    xboxdrv
    xorg.xrandr
    xournalpp
    yq
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable emulation for ARM
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  system.stateVersion = "23.11";

}
