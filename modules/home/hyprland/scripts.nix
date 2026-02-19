{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.file."wallpaper.png".source = ../../../wallpapers/wallpaper.png;
  };
}
