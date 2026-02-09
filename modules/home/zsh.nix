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
        autoload -U colors && colors
        PROMPT=$'%F{221}%n%f %F{white}in%f %F{75}%1~%f\n \u203A '
        export EDITOR=vim
      '';
    };
  };
}
