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
        device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba01812814c9c41-part7";
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
        device = "/dev/disk/by-path/platform-27bcc0000.nvme-nvme-1-part5";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
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
            postCreateHook = "zfs snapshot zroot/root@blank";
          };
          "encrypted" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///run/secrets/zfs-dataset/heimdall/encrypted.key";
            };
          };
          "encrypted/home" = {
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
  fileSystems = {
    "/home".neededForBoot = true;
    "/persist".neededForBoot = true;
  };
}
