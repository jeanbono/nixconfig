{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.zsh;
in
{
  options.modules.home.zsh.enable = lib.mkEnableOption "Zsh (autosuggestion, syntax highlighting, prompt custom)";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        source ~/.nixconfig/modules/home/prompt.zsh
        export EDITOR=vim
      '';
    };
  };
}
