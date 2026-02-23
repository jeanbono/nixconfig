{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.shell;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  options.modules.home.shell.enable = lib.mkEnableOption "Zsh + Alacritty (shell complet)";

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        autoload -U colors && colors
        PROMPT=$'%F{221}%n%f %F{white}in%f %F{75}%1~%f\n \u203A '
        export EDITOR=nvim
      '';
    };

    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          import = [ themeCfg.alacrittyThemeFile ];
        };
        window = {
          opacity = 0.4;
          padding = {
            x = 10;
            y = 10;
          };
        };
        font = {
          normal = {
            family = "MonaspiceNe Nerd Font";
          };
        };
        cursor = {
          style = "Block";
          blink_interval = 0;
        };
      };
    };
  };
}
