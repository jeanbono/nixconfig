{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;

  power-menu = pkgs.writeShellScriptBin "power-menu" (builtins.readFile ../scripts/power-menu.sh);
in
{
  config = lib.mkIf cfg.enable {
    home.file."wallpaper.png".source = ../../../wallpapers/wallpaper.png;

    home.packages = [ power-menu ];
  };
}
