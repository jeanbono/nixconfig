{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.desktop;
in
{
  options.modules.home.desktop.enable = lib.mkEnableOption "Paquets CLI de base et variables Wayland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      curl
      wget
      ripgrep
      fd
      jq
      unzip
    ];

    # Variables utiles Wayland / Electron (côté user)
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
