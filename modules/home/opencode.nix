{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options.kp.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
  };

  imports = [
    inputs.agent-platform.homeModules.default
  ];

  config = lib.mkIf config.kp.opencode.enable {
    home.packages = [
      inputs.agent-platform.inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    programs.agentPlatform = {
      enable = true;
      ecc = {
        enable = true;
        harnesses = [
          "opencode"
        ];
        skills = true;
        memory = true;
        agents = true;
        commands = true;
      };
      allowedRepositories = [
        "${config.home.homeDirectory}/src/agent-platform"
        "${config.home.homeDirectory}/src/bc250-nixos"
      ];
    };
  };
}
