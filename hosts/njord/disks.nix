{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        destroy = false;
        device = "/dev/disk/by-path/platform-27bcc0000.nvme-nvme-1-part4";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
          };
        };
      };
      swap = {
        type = "disk";
        device = "/dev/disk/by-path/platform-27bcc0000.nvme-nvme-1-part5";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "5G";
              content = {
                type = "swap";
                discardPolicy = "both";
                randomEncryption = true;
                priority = 100; # prefer to encrypt as long as we have space for it
              };
            };
          };
        };
      };
      root = {
        type = "disk";
        # One-time migration: wipe the old zpool on p6. Flip back to false
        # after the btrfs install is verified, so future disko runs are safe.
        destroy = true;
        device = "/dev/disk/by-path/platform-27bcc0000.nvme-nvme-1-part6";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root"; # -> /dev/mapper/root
                # Interactive passphrase at boot (no keyFile/passwordFile).
                settings = {
                  allowDiscards = true;
                };
                extraFormatArgs = [
                  "--type"
                  "luks2"
                  "--pbkdf"
                  "argon2id"
                ];
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "@persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/home".neededForBoot = true;
    "/persist".neededForBoot = true;
  };
}