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
  };
}
