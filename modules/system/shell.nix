{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.shell;
in
{
  options.modules.system.shell.enable = lib.mkEnableOption "Zsh (niveau système)";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
  };
}
