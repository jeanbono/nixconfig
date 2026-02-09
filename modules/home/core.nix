{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.core;
in
{
  options.modules.home.core.enable = lib.mkEnableOption "Paquets CLI de base (ripgrep, fd, jq…) et variables Wayland";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
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
