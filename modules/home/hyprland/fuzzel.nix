{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."fuzzel/fuzzel.ini".text = ''
      [main]
      font=MonaspiceNe Nerd Font:size=12
      prompt=  
      placeholder=Rechercher...
      width=40
      lines=10
      terminal=alacritty
      layer=overlay
      icons-enabled=yes
      icon-theme=Papirus-Dark
      fuzzy=yes
      include=${themeCfg.fuzzelThemeFile}

      [border]
      width=2
      radius=8
    '';
  };
}
