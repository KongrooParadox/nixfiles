{ config, inputs, lib, pkgs, stateVersion, ... }:
let
  cfg = config.system;
in
{
  options.system = {
    encoding = lib.mkOption {
      type = lib.types.str;
      default = "UTF-8";
      description = "Encoding to be used throughout the system";
    };
    language = lib.mkOption {
      type = lib.types.str;
      default = "en_GB";
      description = "Language to be used throughout the system";
    };
  };

  config = {
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
      defaultLocale = lib.mkDefault "${cfg.language}.${cfg.encoding}";
      extraLocaleSettings = lib.mkDefault {
        LC_ADDRESS = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_COLLATE = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_CTYPE = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_IDENTIFICATION = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_MEASUREMENT = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_MESSAGES = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_MONETARY = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_NAME = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_NUMERIC = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_PAPER = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_TELEPHONE = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_TIME = lib.mkDefault "${cfg.language}.${cfg.encoding}";
      };
    };

    environment = {
      variables = {
        LANG = lib.mkDefault "${cfg.language}.${cfg.encoding}";
        LC_ALL = lib.mkDefault "${cfg.language}.${cfg.encoding}";
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
    services.openssh = {
      enable = true;
      openFirewall = true;
    };

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
  };
}
