{ pkgs, lib, config, ... }:

let
  cfg = config.modules.git;
in
{
  options.modules.git.enable = lib.mkEnableOption "Git";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = with pkgs; [ git ];
    });
  };
}
