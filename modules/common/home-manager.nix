{
  config,
  host,
  inputs,
  lib,
  stateVersion,
  users,
  isLinux,
  isUnstable,
  ...
}:
let
  cfg = config.kp.home-manager;
  desktop = config.kp.desktop;
  sopsKeyPath =
    if config.kp.impermanence.enable then
      map (user: "/persist/home/${user}/.ssh/id_ed25519") users
    else
      map (user: "${cfg.homeBaseDirectory}/${user}/.ssh/id_ed25519") users;
in
{
  imports =
    if isUnstable then
      if isLinux then
        [ inputs.home-manager-unstable.nixosModules.home-manager ]
      else
        [ inputs.home-manager-unstable.darwinModules.home-manager ]
    else if isLinux then
      [ inputs.home-manager.nixosModules.home-manager ]
    else
      [ inputs.home-manager.darwinModules.home-manager ];

  options.kp = {
    home-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
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
      inputs.impermanence.homeManagerModules.impermanence
      inputs.sops-nix.homeManagerModules.sops
      {
        sops = {
          age = {
            sshKeyPaths = sopsKeyPath;
          };
          defaultSopsFile = ../../secrets/secrets.yaml;
          defaultSopsFormat = "yaml";
        };
      }
    ];
    home-manager = {
      backupFileExtension = "backup";
      useUserPackages = true;
      extraSpecialArgs = {
        inherit
          desktop
          host
          inputs
          isLinux
          isUnstable
          users
          ;
      };
      users = lib.genAttrs users (name: {
        imports = [ inputs.self.outputs.homeManagerModules.default ];
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
