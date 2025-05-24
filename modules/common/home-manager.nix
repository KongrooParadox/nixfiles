{ config, host, inputs, lib, stateVersion, users, system, ...}:
let
  cfg = config.hm;
  desktop = config.desktop;
  isLinux = lib.strings.hasSuffix "linux" system;
in
{
  imports = if lib.versions.majorMinor lib.version == "25.11"
    then
      if isLinux then [ inputs.home-manager-unstable.nixosModules.home-manager ]
        else [ inputs.home-manager-unstable.darwinModules.home-manager ]
    else
      if isLinux then [ inputs.home-manager.nixosModules.home-manager ]
        else [ inputs.home-manager.darwinModules.home-manager ];

  options = {
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
      homeBaseDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home";
        description = lib.mdDoc "Base directory for users (default is linux path)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.sops-nix.homeManagerModules.sops {
        sops = {
          age.sshKeyPaths = map (user: "${cfg.homeBaseDirectory}/${user}/.ssh/id_ed25519") users;
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
          homeDirectory = lib.mkForce "${cfg.homeBaseDirectory}/${name}";
          stateVersion = stateVersion;
        };
        programs.home-manager.enable = true;
      });
    };
  };
}
