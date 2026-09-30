{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.u2f;
in
{
  options.kp.u2f = {
    enable = lib.mkOption {
      default = true;
      description = "Solokey support";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    # https://github.com/solokeys/solo2/blob/main/cli/70-solo2.rules
    services.udev.packages = [
      pkgs.yubikey-personalization
      (pkgs.writeTextFile {
        name = "solo2_udev";
        text = ''
          # NXP LPC55 ROM bootloader (unmodified)
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0021", TAG+="uaccess"
          # NXP LPC55 ROM bootloader (with Solo 2 VID:PID)
          SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="b000", TAG+="uaccess"
          # Solo 2
          SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
          # Solo 2
          SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="beee", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-solo2.rules";
      })
    ];
  };
}
