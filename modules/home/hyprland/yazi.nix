{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
      theme = {
        flavor = {
          use = themeCfg.flavor;
        };
      };
      flavors = {
        ${themeCfg.flavor} = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "yazi";
          rev = "main";
          sha256 = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=d";
        };
      };
    };
  };
}
