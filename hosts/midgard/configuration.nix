{ lib, pkgs, ... }: {

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r root/local/root@blank
    '';
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportAll = true;
      forceImportRoot = true;
      devNodes = "/dev/disk/by-path";
    };
  };

  networking = {
    hostId = "c9e13eac";
    hostName = "midgard";
    networkmanager.enable = true;
    firewall = {
      interfaces = {
        "tailscale0" = {
          allowedTCPPorts = [ 80 443 ];
        };
      };
      # Make sure checkReversePath is disabled for subnet routing
      checkReversePath = lib.mkForce false;
    };
  };

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  time.timeZone = "Europe/Paris";

  security.sudo.wheelNeedsPassword = false;

  users.users.root = {
    openssh.authorizedKeys.keys = (import ../../modules/ssh.nix).keys;
  };

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$y$j9T$hPF6s6mTZ/zrhpR53hLG/0$gYqOtNdDwJxrxn3uMEHULC3zwera8885UbzAnjymBQ3";
    openssh.authorizedKeys.keys = (import ../../modules/ssh.nix).keys;
  };

  # Impermanence state
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  nix = {
    # Perform garbage collection weekly to maintain low disk usage
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      trusted-users = [ "root" "ops" ];
      experimental-features = [
        "nix-command"
          "flakes"
      ];
      auto-optimise-store = true;
    };
  };

    environment = {
      systemPackages = with pkgs; [
        git
        curl
        tmux
        tree
        vim
      ];
    };

  system.stateVersion = "24.11";
}
