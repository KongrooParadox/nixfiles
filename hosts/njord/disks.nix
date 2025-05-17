{
  disko.devices = {
    disk = {
      # boot = {
      #   type = "disk";
      #   device = "/dev/disk/by-partuuid/73a3358a-1ded-4c94-8212-20f64758010c";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       ESP = {
      #         size = "500M";
      #         type = "EF00";
      #         content = {
      #           type = "filesystem";
      #           format = "vfat";
      #           mountpoint = "/boot";
      #           mountOptions = [ "umask=0077" ];
      #         };
      #       };
      #     };
      #   };
      # };
      root = {
        type = "disk";
        device = "/dev/disk/by-partuuid/123a0f8d-23d0-4c3c-8a05-7807915bc897";
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
            postCreateHook = "zfs snapshot zroot/root@blank";
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
