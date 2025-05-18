{ config, host, inputs, lib, stateVersion, users, ...}:
let
  cfg = config.hm;
  desktop = config.desktop;
in
{
  imports = if lib.versions.majorMinor lib.version >= "25.05"
    then [ inputs.home-manager-unstable.nixosModules.home-manager ]
    else [ inputs.home-manager.nixosModules.home-manager ];

  options.hm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc "Whether to enable home-manager modules";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = users;
      description = lib.mdDoc "List of users to enable home-manager for";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops {
        sops = {
          age.sshKeyPaths = map (user: "/home/${user}/.ssh/id_ed25519") users;
          defaultSopsFile = ../../secrets/secrets.yaml;
          defaultSopsFormat = "yaml";
          secrets."anthropic-api-key" = {};
        };
      }
    ];
    home-manager = {
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs host desktop users; };
      users = lib.genAttrs users (name: {
        imports = [ ../home ];
        home = {
          username = name;
          homeDirectory = lib.mkForce "/home/${name}";
          stateVersion = stateVersion;
        };
        programs.home-manager.enable = true;
      });
    };
  };
}
