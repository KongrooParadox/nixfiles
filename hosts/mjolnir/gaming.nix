{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.mjolnir.role == "gaming") {
    boot.kernelParams = [ "amdgpu.virtual_display=0000:01:00.0,1" ];

    jovian = {
      decky-loader.enable = false;

      devices.steamdeck = {
        enable = false;
      };

      steam = {
        enable = true;
        autoStart = true;
        user = "ops";
        desktopSession = "hyprland";
      };

      steamos = {
        enableHdmiCecIntegration = false;
        enableZram = false;
      };
    };

    kp.gaming = {
      retrodeck.enable = true;
      steam.enable = false; # Jovian supplies Steam
      sunshine = {
        enable = true;
        virtualMonitor = false;
      };
    };

    systemd.services.display-manager.serviceConfig.ExecStartPre = lib.mkForce [
      "${pkgs.coreutils}/bin/rm -f /etc/sddm.conf.d/zzt-steamos-temp-login.conf"
      "${pkgs.coreutils}/bin/rm -f /etc/sddm.conf.d/zzt-holo-temp-login.conf"
    ];
  };
}
