{ host, self, ... }:
{
  imports = [
    "${self}/hosts/${host}"
    ./fonts.nix
    ./home-manager.nix
    ./stylix.nix
    ./system.nix
  ];

  nixpkgs.config.allowUnfree = true;

  desktop.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
