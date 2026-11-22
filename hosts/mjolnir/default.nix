{
  lib,
  ...
}:
{
  imports = [
    ./base.nix
    ./gaming.nix
    ./llm.nix
    ./hyprland.nix
    ./steam-streaming.nix
  ];

  options.mjolnir.role = lib.mkOption {
    type = lib.types.enum [
      "gaming"
      "llm"
    ];
    default = "gaming";
    description = "Which mjolnir specialisation this system boots.";
  };

  config = {
    # Gaming is the default generation; the LLM server is a specialisation of
    # the same hardware, selectable in the systemd-boot menu or via
    # `mjolnir-role`.
    specialisation.mjolnir-llm = {
      inheritParentConfig = true;
      configuration = {
        mjolnir.role = "llm";
      };
    };

    # ROCm variant of the LLM specialisation: same headless llama.cpp server,
    # AMD HSA backend instead of Vulkan, to test the gfx1013 ROCm path and
    # benchmark it against the Vulkan build. Experimental; needs the community
    # bc250-rocm patches.
    specialisation.mjolnir-llm-rocm = {
      inheritParentConfig = true;
      configuration = {
        mjolnir.role = "llm";
        kp.llm.llamaCpp.acceleration = "rocm";
        kp.llm.llamaCpp.hsaOverrideGfxVersion = "10.3.0";
      };
    };
  };
}
