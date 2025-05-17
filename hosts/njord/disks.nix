{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        destroy = false;
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0512Z_0ba018e3a2b8f229-part4";
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
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0512Z_0ba018e3a2b8f229-part5";
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
        destroy = false;
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0512Z_0ba018e3a2b8f229-part6";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      zpool = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          compression = "zstd";
          xattr = "sa";
        };
        options = {
          ashift = "12";
          cachefile = "none";
        };

        datasets = {
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot zpool/root@blank";
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              "com.sun:auto-snapshot" = "true";
              mountpoint = "legacy";
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
