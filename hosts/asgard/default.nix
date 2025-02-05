{ host, modulesPath, lib, ... }:
{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  boot = {
    tmp.cleanOnBoot = true;
    growPartition = true;
    loader = {
      grub = {
        enable = false;
        device = lib.mkDefault "/dev/vda";
      };
      systemd-boot.enable = lib.mkForce false;
      generic-extlinux-compatible.enable = true;
    };
  };

  reverseProxy.enable = true;
  home-assistant = {
    enable = true;
    hostname = "${host}.tavel.kongroo.ovh";
  };

  dns-server = {
    enable = true;
    publicDomain = "tavel.kongroo.ovh";
    localDomain = "skynet.local";
    mapping = {
      "tasmota-desk.skynet.local" = "10.10.111.28";
      "tasmota-window.skynet.local" = "10.10.111.29";
      "tasmota-nas.skynet.local" = "10.10.111.27";
      "tasmota-tv.skynet.local" = "10.10.111.14";
      "njord.skynet.local" = "10.10.111.26,10.10.111.31";
      "baldur.skynet.local" = "10.10.111.20,10.10.111.21,2a01:cb1d:824f:1000:7f0b:431c:2066:a6ce";
      "asgard.skynet.local" = "10.10.111.100,2a01:cb1d:824f:1000:44a0:293a:69fa:1c5f";
      "yggdrasil.skynet.local" = "10.10.111.101,2a01:cb1d:824f:1000:24d1:69f:4b2c:78b9";
      "heimdall.skynet.local" = "10.10.111.102";
      "kronos.skynet.local" = "10.10.111.103";
      "thor.skynet.local" = "10.10.111.104";
      "livebox.skynet.local" = "10.10.111.254";
    };
  };

  tailscale = {
    advertisedRoutes = [ "10.10.111.0/24" ];
    exitNode = false;
    subnetRouter = true;
  };
}
