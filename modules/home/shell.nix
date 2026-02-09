{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.shell;
in
{
  options.modules.home.shell.enable = lib.mkEnableOption "Zsh + Kitty (shell complet)";

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

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        background_opacity = "0.98";
        enable_audio_bell = "no";
        cursor_shape = "block";
        cursor_shape_unfocused = "hollow";
        cursor_blink_interval = 0;
        strip_trailing_spaces = "smart";
        window_padding_width = 10;
        background = "#1e1e1e";
        foreground = "#d4d4d4";
        shell_integration = "no-cursor";
      };
    };
  };
}
