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
                pool = "root";
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
                pool = "root";
              };
            };
          };
        };
      };
      hdd-1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:17.0-ata-2";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rust";
              };
            };
          };
        };
      };
      hdd-2 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rust";
              };
            };
          };
        };
      };
      hdd-3 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-2";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rust";
              };
            };
          };
        };
      };
      # 128 Go SSD for L2ARC Cache
      cache = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-3";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rust";
              };
            };
          };
        };
      };
      ssd-1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-4";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fast";
              };
            };
          };
        };
      };
      ssd-2 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-5";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fast";
              };
            };
          };
        };
      };
      # nvme0 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "rust";
      #         };
      #       };
      #     };
      #   };
      # };
      # nvme1 = {
      #   type = "disk";
      #   device = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       zfs = {
      #         size = "100%";
      #         content = {
      #           type = "zfs";
      #           pool = "rust";
      #         };
      #       };
      #     };
      #   };
      # };
    };
    zpool = {
      root = {
        type = "zpool";
        rootFsOptions = {
          # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
        };
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
        options = {
          ashift = "12";
          cachefile = "none";
        };

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
            # postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^root/local/root@blank$' || zfs snapshot root/local/root@blank";
            postCreateHook = "zfs snapshot root/local/root@blank";
          };
        };
      };
      fast = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "mirror";
                members = [ "ssd-1" "ssd-2" ];
              }
            ];
          };
        };
        options = {
          ashift = "9";
          cachefile = "none";
        };

        datasets = {
          "fast" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "fast/vm" = {
            type = "zfs_fs";
            mountpoint = "/mnt/vm";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
      rust = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz1";
                members = [ "hdd-1" "hdd-2" "hdd-3" ];
              }
            ];
            cache = [ "cache" ];
          };
        };
        options = {
          ashift = "12";
          cachefile = "none";
        };

        datasets = {
          "data" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "data/backup" = {
            type = "zfs_fs";
            mountpoint = "/mnt/backup";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
          };
          "data/compute" = {
            type = "zfs_fs";
            mountpoint = "/mnt/compute";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
          };
          "data/media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/media";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
}
