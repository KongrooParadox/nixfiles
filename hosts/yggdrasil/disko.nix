{
  disko.devices = {
    disk = {
      boot-1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:14.0-usbv3-0:2:1.0-scsi-0:0:0:0";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
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
      boot-2 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:14.0-usbv2-0:3:1.0-scsi-0:0:0:0";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-fallback";
                mountOptions = [ "umask=0077" ];
              };
            };
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
      # hdd-1 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:02:00.0-ata-1";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # hdd-2 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:02:00.0-ata-3";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # hdd-3 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:02:00.0-ata-4";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # hdd-4 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:02:00.0-ata-5";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # ssd-1 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:02:00.0-ata-2";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # ssd-2 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:00:17.0-ata-2";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # nvme0 = {
      #   type = "disk";
      #   device = "/dev/nvme0n1";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
      # nvme1 = {
      #   type = "disk";
      #   device = "/dev/nvme1n1";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "zmain";
      #         };
      #       };
      #     };
      #   };
      # };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [ "boot-1" "boot-2" ];
              }
            ];
          };
        };
        options.cachefile = "none";
        rootFsOptions = {
          # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
        };
        # Replace with 9 for disks with 512 byte physical sectors
        # Run 'lsblk -S -o NAME,PHY-SEC' to check (SATA/SCSI)
        # Run 'nvme id-ns /dev/nvmeXnY -H | grep "LBA Format"' (NVME)
        options.ashift = "12";

        datasets = {
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            # Used by services.zfs.autoSnapshot options.
            options."com.sun:auto-snapshot" = "true";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot zroot/local/root@blank";
          };
        };
      };
      # zmain = {
      #   type = "zpool";
      #   mode = {
      #     topology = {
      #       type = "topology";
      #       vdev = [
      #         {
      #           mode = "raidz2";
      #           members = [ "hdd-1" "hdd-2" "hdd-3" "hdd-4" ];
      #         }
      #       ];
      #       cache = [ "ssd-1" "ssd-2" ];
      #       # log = {
      #       #   mode = "mirror";
      #       #   members = [ "nvme0" "nvme1" ];
      #       # };
      #     };
      #   };
      #   options.cachefile = "none";
      #   rootFsOptions = {
      #     # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
      #     acltype = "posixacl";
      #     atime = "off";
      #     compression = "zstd";
      #     mountpoint = "none";
      #     xattr = "sa";
      #   };
      #   # Replace with 9 for disks with 512 byte physical sectors
      #   # Run 'lsblk -S -o NAME,PHY-SEC' to check (SATA/SCSI)
      #   # Run 'nvme id-ns /dev/nvmeXnY -H | grep "LBA Format"' (NVME)
      #   options.ashift = "12";
      #
      #   datasets = {
      #     "data" = {
      #       type = "zfs_fs";
      #       options.mountpoint = "none";
      #     };
      #     "data/backup" = {
      #       type = "zfs_fs";
      #       mountpoint = "/mnt/backup";
      #       options."com.sun:auto-snapshot" = "false";
      #     };
      #     "data/compute" = {
      #       type = "zfs_fs";
      #       mountpoint = "/mnt/compute";
      #       options."com.sun:auto-snapshot" = "true";
      #     };
      #     "data/media" = {
      #       type = "zfs_fs";
      #       mountpoint = "/mnt/media";
      #       options."com.sun:auto-snapshot" = "true";
      #     };
      #   };
      # };
    };
  };
}
