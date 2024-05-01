# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    # grub = {
    #   enable = true;
    #   device = "nodev";
    #   useOSProber = true;
    #   configurationLimit = 10;
    # };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
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

  networking.hostName = "baldur-nix";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  security.polkit.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # audio
    security.rtkit.enable = true;
    services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

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

  environment.localBinInPath = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    android-tools
    bat
    buildah
    cmake
    curl
    direnv
    discord
    displaylink
    dnsutils
    evolution
    fd
    fzf
    gcc
    gnome.adwaita-icon-theme
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
    nettools
    nmap
    nodejs_21
    openvpn
    parsec-bin
    pavucontrol
    peek
    pkg-config
    podman
    protonmail-bridge
    python3
    python311Packages.pip
    remmina
    ripgrep
    rsync
    samba
    screenkey
    spotify
    subversion
    sudo
    tcpdump
    terraform
    terraform-ls
    traceroute
    tree
    unzip
    usbutils
    vagrant
    virtualenv
    vlc
    wget
    wireguard-tools
    xboxdrv
    xorg.xrandr
    xournalpp
    youtube-dl
    yq
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Enable emulation for ARM
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
