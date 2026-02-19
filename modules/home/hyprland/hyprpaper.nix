{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    # ── Hyprpaper (fond d'écran) ───────────────────────────────────
    services.hyprpaper = {
      enable = true;
      settings = {
        wallpaper = [
          {
            monitor = "DP-1";
            path = "$HOME/wallpaper.png";
            fit_mode = "cover";
          }
          {
            monitor = "DP-3";
            path = "$HOME/wallpaper.png";
            fit_mode = "cover";
          }
        ];
        splash = false;
      };
    };
  };
}
