{
  config,
  inputs,
  lib,
  pkgs,
  users,
  ...
}:
let
  cfg = config.kp.gaming.retrodeck;
  appId = "net.retrodeck.retrodeck";
  esFindRules = pkgs.writeText "retrodeck-es-find-rules.xml" ''
    <?xml version="1.0"?>
    <ruleList>
        <emulator name="EDEN-NIX">
            <rule type="staticpath">
                <entry>${pkgs.eden}/bin/eden</entry>
            </rule>
        </emulator>
        <emulator name="XENIA-NIX">
            <rule type="staticpath">
                <entry>${pkgs.xenia-canary}/bin/xenia_canary</entry>
            </rule>
        </emulator>
    </ruleList>
  '';
  esSystems = pkgs.writeText "retrodeck-es-systems.xml" ''
    <?xml version="1.0"?>
    <systemList>
        <system>
            <name>switch</name>
            <fullname>Nintendo Switch</fullname>
            <path>%ROMPATH%/switch</path>
            <extension>.nca .NCA .nro .NRO .nso .NSO .nsp .NSP .xci .XCI</extension>
            <command label="Eden (Nixpkgs)">flatpak-spawn --host ${pkgs.eden}/bin/eden -f -g "%ROMRAW%"</command>
            <platform>switch</platform>
            <theme>switch</theme>
        </system>
        <system>
            <name>xbox360</name>
            <fullname>Microsoft Xbox 360</fullname>
            <path>%ROMPATH%/xbox360</path>
            <extension>.iso .ISO .xex .XEX .zar .ZAR</extension>
            <command label="Xenia Canary (Nixpkgs)">flatpak-spawn --host ${pkgs.xenia-canary}/bin/xenia_canary --fullscreen "%ROMRAW%"</command>
            <platform>xbox360</platform>
            <theme>xbox360</theme>
        </system>
    </systemList>
  '';
  tmpfilesRules = lib.concatMap (
    user:
    let
      account = config.users.users.${user};
      retrodeckDirectory = "${account.home}/retrodeck";
      esDeDirectory = "${retrodeckDirectory}/ES-DE";
      customSystemsDirectory = "${esDeDirectory}/custom_systems";
    in
    [
      "d ${retrodeckDirectory} - :${user} :${account.group} - -"
      "d ${esDeDirectory} - :${user} :${account.group} - -"
      "d ${customSystemsDirectory} - :${user} :${account.group} - -"
      "L+ ${customSystemsDirectory}/es_find_rules.xml - - - - ${esFindRules}"
      "L+ ${customSystemsDirectory}/es_systems.xml - - - - ${esSystems}"
    ]
  ) users;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.kp.gaming.retrodeck.enable = lib.mkEnableOption "RetroDECK and ES-DE custom systems";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      eden
      xenia-canary
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    hardware.uinput.enable = true;
    services.udev.packages = [ pkgs.game-devices-udev-rules ];
    # Steam owns and rewrites shortcuts.vdf; add the RetroDECK shortcut in Steam once.
    services.flatpak = {
      enable = true;
      packages = [ appId ];
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
      overrides.settings.${appId} = {
        # Replace RetroDECK's upstream host-wide filesystem grant with required paths.
        Context.filesystems = [
          "!host"
          "~/retrodeck"
          "/nix/store:ro"
          "/run/media:ro"
        ];
        # ES-DE uses flatpak-spawn to launch the host-side Nix emulators.
        "Session Bus Policy"."org.freedesktop.Flatpak" = "talk";
      };
    };

    # Nix owns these two ES-DE files; tmpfiles replaces existing targets on activation.
    systemd.tmpfiles.rules = tmpfilesRules;
  };
}
