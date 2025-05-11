{ config, host, inputs, lib, stateVersion, users, ...}:
let
  cfg = config.hm;
  desktop = config.desktop;
in
{
  imports = if lib.versions.majorMinor lib.version == "25.05"
    then [ inputs.home-manager-unstable.darwinModules.home-manager ]
    else [ inputs.home-manager.darwinModules.home-manager ];

  options = {
    desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc "Whether to enable desktop specific settings & programs";
      };
      environment = lib.mkOption {
        type = lib.types.str;
        default = "macos";
        description = lib.mdDoc "Desktop environment";
      };
    };
    hm = {
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
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops {
        sops = {
          age.sshKeyPaths = map (user: "/Users/${user}/.ssh/id_ed25519") users;
          defaultSopsFile = ../../secrets/secrets.yaml;
          defaultSopsFormat = "yaml";
          secrets."anthropic-api-key" = {};
        };
      }
    ];
    home-manager = {
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs host desktop users; };
      users = lib.genAttrs users (name: {
        imports = [ ../home ];
        home = {
          username = name;
          homeDirectory = lib.mkForce "/Users/${name}";
          stateVersion = stateVersion;
        };
        programs.home-manager.enable = true;
      });
    };
  };
}
