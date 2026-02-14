{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.tools;
in
{
  options.modules.home.tools.enable = lib.mkEnableOption "Outils CLI de base";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      curl
      wget
      ripgrep
      fd
      jq
      unzip
    ];
  };
}
