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
            bcachefs_root = {
              size = "100%";
              content = {
                type = "bcachefs";
                # This refers to a filesystem in the `bcachefs_filesystems` attrset below.
                filesystem = "mounted_subvolumes_single_disk";
                label = "group_a.root";
                extraFormatArgs = [
                  "--discard"
                ];
              };
            };
          };
        };
      };
    };

    bcachefs_filesystems = {
      # Example showing mounted subvolumes in a single-disk configuration.
      mounted_subvolumes_single_disk = {
        type = "bcachefs_filesystem";
	uuid = "8b8c4eda-8537-4424-92b0-ff83263e0af9";
        passwordFile = "/tmp/secret.key";
        extraFormatArgs = [
          "--compression=zstd"
        ];
        subvolumes = {
          # Subvolume name is different from mountpoint.
          "subvolumes/root" = {
            mountpoint = "/";
            mountOptions = [
              "verbose"
            ];
          };
          # Subvolume name is the same as the mountpoint.
          "subvolumes/home" = {
            mountpoint = "/home";
          };
          # Nested subvolume doesn't need a mountpoint as its parent is mounted.
          "subvolumes/home/robot" = {
          };
          # Parent is not mounted so the mountpoint must be set.
          "subvolumes/nix" = {
            mountpoint = "/nix";
          };
          # Subvolume name is the same as the mountpoint.
          "subvolumes/persist" = {
            mountpoint = "/persist";
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
