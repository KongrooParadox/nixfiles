{
  disko.devices = {
    disk = {
      boot-1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-4";
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
        device = "/dev/disk/by-path/pci-0000:02:00.0-ata-5";
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
      log-1 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1";
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
      log-2 = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:03:00.0-nvme-1";
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
            options = {
              mountpoint = "none";
            };
          };
          "local/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          "local/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              "com.sun:auto-snapshot" = "true";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false";
            postCreateHook = "zfs snapshot root/local/root@blank";
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
            log = [
              {
                mode = "mirror";
                members = [ "log-1" "log-2" ];
              }
            ];
          };
        };
        options = {
          ashift = "12";
          cachefile = "none";
        };

        datasets = {
          "data" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///run/secrets/zfs-dataset/yggdrasil/rust.key";
            };
          };
          "data/backup" = {
            type = "zfs_fs";
            mountpoint = "/mnt/backup";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
          "data/compute" = {
            type = "zfs_fs";
            mountpoint = "/mnt/compute";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
          "data/media" = {
            type = "zfs_fs";
            mountpoint = "/mnt/media";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
