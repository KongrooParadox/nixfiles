{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.desktop.enable {
    security.rtkit.enable = true;
    services = {
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
        };
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };
}
