{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.kitty;
in
{
  options.modules.home.kitty.enable = lib.mkEnableOption "Terminal Kitty (thème sombre, opacité, padding)";

  config = lib.mkIf cfg.enable {
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
