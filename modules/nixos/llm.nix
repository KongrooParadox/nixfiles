{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kp.llm;
in
{
  options.kp.llm = {
    enable = lib.mkEnableOption "LLM coding tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ opencode ];
  };

}
