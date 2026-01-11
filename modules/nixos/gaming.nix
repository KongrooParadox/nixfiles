{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.gaming;
in
{
  options.kp.gaming = {
    steam.enable = lib.mkEnableOption "Steam";
    sunshine = {
      enable = lib.mkEnableOption "Sunshine game streaming backend";
      virtualMonitor = lib.mkEnableOption "Virtual Monitor for Sunshine";
    };
  };

  config = (
    lib.mkMerge [
      (lib.mkIf (cfg.sunshine.enable && cfg.sunshine.virtualMonitor) {
        boot.kernelParams = [ "video=HDMI-A-1:2560x1600R@60D" ];

        hardware.display.edid.packages = [
          (pkgs.runCommand "edid-custom" { } ''
            mkdir -p $out/lib/firmware/edid
            base64 -d > "$out/lib/firmware/edid/custom1.bin" <<'EOF'
            AP///////wBMLQkOAAAOAAEbAQOAjlB4KiOtpFRNmSYPR0q974BxT4HAgQCBgJUAqcCzAAEBCOgA
            MPJwWoCwWIoAuqlCAAAeAAAA/QAYSw+HPAAKICAgICAgAAAA/ABTeW5jTWFzdGVyCiAgAAAA/wBI
            MUFLNTAwMDAwCiAgAQICA0rwV2EQHwQTBRQgISJdXl9gZWZiY2QHFgMSIwkHB4MBAADiAA/jBcMB
            bgMMABAAuDwgAIABAgMEZ9hdxAF4gAPjDwHg4wYNAQI6gBhxOC1AWCxFALqpQgAAHmYhVqpRAB4w
            Ro8zALqpQgAAHgAAAAAAAAAAAAAAAAAAAAAAlA==
            EOF
          '')
        ];
        hardware.display.outputs."HDMI-A-1".edid = "custom1.bin";

      })
      {
        programs.steam = lib.mkIf cfg.steam.enable {
          enable = true;
          remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
          dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
          localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        };
      }
      {
        services = lib.mkIf cfg.sunshine.enable {
          logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
          sunshine = {
            enable = true;
            autoStart = true;
            capSysAdmin = true;
            openFirewall = true;
          };
        };
      }
    ]
  );
}
