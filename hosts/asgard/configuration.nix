{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    tmux
    vim
  ];

  boot = {
    tmp.cleanOnBoot = true; growPartition = true;
    loader = {
      generic-extlinux-compatible.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        enable = false;
        device = lib.mkDefault "/dev/vda";
      };
    };
  };

  services = {
    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ~/.ssh/id_ed25519.pub)
    ];
  };

  networking = {
    hostName = "asgard";
    networkmanager.enable = true;
  };

  nix.settings = {
    trusted-users = [ "root" "ops" ];
    experimental-features = [
      "nix-command"
        "flakes"
    ];
  };
  system.stateVersion = "24.05";
}
