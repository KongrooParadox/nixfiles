{
  host,
  inputs,
  lib,
  modulesPath,
  sdImageEnable ? false,
  ...
}:
let
  pki = inputs.k8s-nix-infra.outPath + "/secrets/pki";
  nodePki = pki + "/${host}";
  ageFiles = {
    etcdServerKey = nodePki + "/etcd-server.key.age";
    apiserverEtcdKey = nodePki + "/apiserver-etcd-client.key.age";
    apiserverKey = nodePki + "/apiserver.key.age";
    controllerManagerKey = nodePki + "/controller-manager.key.age";
    schedulerKey = nodePki + "/scheduler.key.age";
    apiserverKubeletKey = nodePki + "/apiserver-kubelet-client.key.age";
    frontProxyKey = nodePki + "/front-proxy-client.key.age";
    serviceAccountKey = pki + "/service-account.key.age";
    kubeletServerKey = nodePki + "/kubelet-server.key.age";
    kubeletClientKey = nodePki + "/kubelet-client.key.age";
    kubeProxyKey = nodePki + "/kube-proxy.key.age";
    flannelKey = nodePki + "/flannel-client.key.age";
    addonManagerKey = nodePki + "/addon-manager.key.age";
  }
  // lib.optionalAttrs (host == "pi1") {
    bootstrapKey = nodePki + "/bootstrap.key.age";
  };
  publicFiles = {
    etcdCa = pki + "/etcd-ca.crt";
    etcdServerCert = nodePki + "/etcd-server.crt";
    apiserverEtcdCert = nodePki + "/apiserver-etcd-client.crt";
    kubernetesCa = pki + "/kubernetes-ca.crt";
    apiserverCert = nodePki + "/apiserver.crt";
    controllerManagerCert = nodePki + "/controller-manager.crt";
    schedulerCert = nodePki + "/scheduler.crt";
    apiserverKubeletCert = nodePki + "/apiserver-kubelet-client.crt";
    frontProxyCert = nodePki + "/front-proxy-client.crt";
    kubeletServerCert = nodePki + "/kubelet-server.crt";
    kubeletClientCert = nodePki + "/kubelet-client.crt";
    kubeProxyCert = nodePki + "/kube-proxy.crt";
    flannelCert = nodePki + "/flannel-client.crt";
    addonManagerCert = nodePki + "/addon-manager.crt";
  }
  // lib.optionalAttrs (host == "pi1") {
    bootstrapCert = nodePki + "/bootstrap.crt";
  };
in
{
  imports = [
    inputs.k8s-nix-infra.nixosModules.cluster
    inputs.k8s-nix-infra.nixosModules.stackedTopology
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ]
  ++ lib.optional sdImageEnable (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ++ lib.optional sdImageEnable {
    sdImage = {
      compressImage = false;
      expandOnBoot = true;
    };
  }
  # When the sd-image module is not loaded, provide the root filesystem
  # config that it would normally provide, so the NixOS assertion passes.
  # The sd-image module uses /dev/disk/by-label/NIXOS_SD which is the
  # label set during initial flashing.
  ++ lib.optional (!sdImageEnable) {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "nofail"
          "noauto"
        ];
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Disable the all-hardware profile to avoid pulling in Rockchip-specific modules
  # (dw-hdmi, dw-mipi-dsi, rockchipdrm, etc.) that don't exist in the linux-rpi kernel.
  hardware.enableAllHardware = lib.mkForce false;

  boot = {
    extraModulePackages = lib.mkForce [ ];
    # kernelPackages = pkgs.linuxPackages;
    initrd.availableKernelModules = [ "uas" ];
    loader.systemd-boot.enable = lib.mkForce false;
    # The sd-image base profile auto-enables zfs in boot.supportedFilesystems
    # because zfs-user is available on aarch64, but the linux-rpi kernel has
    # no zfs kernel module. Override supportedFilesystems to drop zfs.
    supportedFilesystems = lib.mkForce [
      "ext2"
      "ext3"
      "ext4"
      "btrfs"
      "cifs"
      "f2fs"
      "ntfs"
      "vfat"
      "xfs"
    ];
  };

  cluster = {
    domain = "cluster.local";
    enable = true;
    name = "skynet";
    podCidr = "10.240.0.0/16";
    serviceCidr = "10.241.0.0/16";
    secrets = {
      provider = "agenix";
      inherit ageFiles publicFiles;
    };
  };
  hardware.raspberry-pi.firmware.uboot.enable = true;
  kp = {
    home-manager.enable = false;
    tailscale.enable = false;
  };
  # sdImage settings are only valid when the sd-image module is loaded.
  # This is handled by the conditional import above.
  services.timesyncd.enable = true;
}
