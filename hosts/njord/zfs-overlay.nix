self: super:
let
  zfsVersion = "2.3.2";
  zfsSrc = self.fetchFromGitHub {
    owner = "openzfs";
    repo = "zfs";
    rev = "zfs-${zfsVersion}";
    # You'll need to replace this with the correct hash
    sha256 = "sha256-lnjRCfHbpmINgo7QK02vaZ81+0mQC9QrpuK3Zv59MZA=";
  };
in {
  # Override just the ZFS module
  # while keeping the asahi kernel
  linuxPackages_asahi = super.linuxPackages_asahi.extend (linuxSelf: linuxSuper: {
    zfs = linuxSuper.zfs.overrideAttrs (_: {
      name = "zfs-kernel-${zfsVersion}-${linuxSuper.kernel.version}";
      inherit zfsSrc;
      src = zfsSrc;
    });
  });
  
  # Override the userspace tools as well
  zfs = super.zfs.overrideAttrs (_: {
    name = "zfs-user-${zfsVersion}";
    inherit zfsSrc;
    src = zfsSrc;
  });
}

