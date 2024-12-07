{ ... } :
{
  hardware = {
    asahi = {
      experimentalGPUInstallMode = "replace";
      peripheralFirmwareDirectory = ./firmware;
      useExperimentalGPUDriver = true;
      withRust = true;
      setupAsahiSound = true;
    };
  };
}
