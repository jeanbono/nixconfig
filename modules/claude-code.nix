{ pkgs, lib, config, ... }:

let
  cfg = config.modules.claude-code;
in
{
  options.modules.claude-code.enable = lib.mkEnableOption "Claude Code CLI";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = [ pkgs.claude-code ];
    });
  };
}
