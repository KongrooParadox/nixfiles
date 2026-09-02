{ config, pkgs, ... }:
let
  awsCredentials = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."oci/credentials".path;
in
{
  home = {
    file.".aws/credentials".source = awsCredentials;
    packages = [ pkgs.s5cmd ];
  };

  programs.zsh.shellAliases.s5oci = "s5cmd --endpoint-url https://axeoau7ddnjt.compat.objectstorage.eu-marseille-1.oci.customer-oci.com";

  sops.secrets."oci/credentials" = { };
}
