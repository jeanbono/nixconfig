{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.plasma;
in
{
  options.modules.home.plasma.enable = lib.mkEnableOption "Thème Plasma Nordic + Papirus-Dark";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nordic
      papirus-icon-theme
    ];

    # Variables utiles Wayland / Electron (côté user)
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    programs.plasma.workspace = {
      lookAndFeel = "Nordic";
      colorScheme = "Nordic";
      theme = "Nordic";
      iconTheme = "Papirus-Dark";
      cursor.theme = "Nordic-cursors";
    };
  };
}
