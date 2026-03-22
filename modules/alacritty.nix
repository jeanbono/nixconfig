{ pkgs, lib, config, ... }:

let
  cfg = config.modules.alacritty;
in
{
  options.modules.alacritty.enable = lib.mkEnableOption "Alacritty (terminal GPU)";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_:
      { nixosConfig, ... }:
      let
        themeCfg = nixosConfig.modules.theme.catppuccin;
      in
      {
        programs.alacritty = {
          enable = true;
          settings = {
            general.import = [ themeCfg.alacrittyThemeFile ];
            window = {
              opacity = 0.4;
              padding = { x = 10; y = 10; };
            };
            font.normal.family = "MonaspiceNe Nerd Font";
            cursor = {
              style = "Block";
              blink_interval = 0;
            };
          };
        };
      }
    );
  };
}
