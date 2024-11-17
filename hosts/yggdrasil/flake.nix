{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs = inputs@{ self, sops-nix, nixpkgs, ... }: {
    nixosConfigurations.yggdrasil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        inputs.disko.nixosModules.disko
        sops-nix.nixosModules.sops {
          sops = {
            age = {
              sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
            };
            defaultSopsFile = ../../secrets/secrets.yaml;
            defaultSopsFormat = "yaml";
            secrets."zfs-dataset/root.key" = {};
            secrets."zfs-dataset/fast.key" = {};
            secrets."zfs-dataset/rust.key" = {};
          };
        }
        ./disko.nix
      ];
    };
  };
}
