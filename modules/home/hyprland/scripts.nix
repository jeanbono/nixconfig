{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file."wallpaper.png".source = ../../../wallpapers/wallpaper.png;

    home.file."bin/power-menu.sh".source = ../scripts/power-menu.sh;
    home.file."bin/power-menu.sh".executable = true;
  };
}
