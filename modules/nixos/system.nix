{ inputs, pkgs, stateVersion, ... }:
{
  system.stateVersion = stateVersion;

  nix = {
    # sets NIX_PATH to flake input for nixd
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.auto-optimise-store = true;
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
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

  environment = {
    variables = {
      LANG = "en_GB.UTF-8";
      LC_ALL = "en_GB.UTF-8";
    };
    localBinInPath = true;
    systemPackages = with pkgs; [
      acpi
      age
      bat
      btop
      cmake
      curl
      direnv
      dnsutils
      fd
      fzf
      gcc
      gnumake
      ipcalc
      iptables
      jq
      lftp
      lsb-release
      nettools
      nmap
      ripgrep
      rsync
      sops
      sudo
      ssh-to-age
      tcpdump
      traceroute
      tree
      unzip
      virtualenv
      wget
      yad
      yq
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 7200;
      max-cache-ttl = 43200;
    };
  };

  programs.zsh.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

}
