{
  config,
  impermanence,
  lib,
  ...
}:
let
  cfg = config.impermanence;
in
{
  options.impermanence = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to enable impermanence module.";
    };

    extraDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "/var/lib/my-service" ];
      description = lib.mdDoc "List of directories to add to persistent storage";
    };
  };

  imports = [ impermanence.nixosModules.impermanence ];

  config = lib.mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ]
      ++ cfg.extraDirectories;
      files = [
        "/etc/machine-id"
      ];
    };
    # Needed for home-manager allowOther option
    programs.fuse.userAllowOther = true;

    services.openssh = {
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

    sops = {
      age = {
        keyFile = "/persist/.age.txt";
        sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
  };
}
