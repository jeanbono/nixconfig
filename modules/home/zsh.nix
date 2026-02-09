{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      source ~/.dotfiles/modules/home/prompt.zsh
      export EDITOR=vim
    '';
  };
}
