{
  config,
  host,
  inputs,
  isLinux,
  isUnstable,
  lib,
  stateVersion,
  users,
  ...
}:
let
  cfg = config.kp.home-manager;
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
        description = "Whether to enable home-manager modules";
      };
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = users;
        description = "List of users to enable home-manager for";
      };
      homeBaseDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home";
        description = "Base directory for users (default is linux path)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      inputs.self.outputs.homeModules.default
    ];
    home-manager = {
      backupCommand = "rm -f";
      extraSpecialArgs = {
        inherit
          host
          inputs
          isLinux
          isUnstable
          users
          ;
      };
      useUserPackages = true;
      users = lib.genAttrs users (name: {
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
