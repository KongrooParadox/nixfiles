{ config, host, inputs, lib, stateVersion, username, ...}:
let
  cfg = config.hm;
  desktop = config.desktop;
in
{
  imports = if lib.versions.majorMinor lib.version == "25.05"
    then [ inputs.home-manager-unstable.nixosModules.home-manager ]
    else [ inputs.home-manager.nixosModules.home-manager ];

  options.hm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable home-manager modules";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops {
        sops = {
          age.sshKeyPaths = [
            "/home/${username}/.ssh/id_ed25519"
          ];
          defaultSopsFile = ../../secrets/secrets.yaml;
          defaultSopsFormat = "yaml";
          secrets."anthropic-api-key" = {};
        };
      }
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs username host desktop; };
      users.${username} = {
        imports = [ ../home ];
        home = {
          username = "${username}";
          homeDirectory = lib.mkForce "/home/${username}";
          stateVersion = stateVersion;
        };
        programs.home-manager.enable = true;
      };
    };

  };
}
