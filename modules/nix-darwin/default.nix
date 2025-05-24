{
  host,
  self,
  ...
}:
{
  imports = [
    "${self}/hosts/${host}"
    "${self}/modules/common"
    ./desktop.nix
    ./system.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
