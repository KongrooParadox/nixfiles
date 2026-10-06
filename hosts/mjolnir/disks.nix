{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_HS_2000GB_22400B443101";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "5G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        swap = {
          size = "16G";
          content.type = "swap";
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
