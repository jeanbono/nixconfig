{ pkgs, lib, config, ... }:

let
  cfg = config.modules.tools;
in
{
  options.modules.tools.enable = lib.mkEnableOption "Outils CLI de base";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = with pkgs; [
        ripgrep
        fd
        jq
        unzip
        fastfetch
      ];
    });
  };
}
