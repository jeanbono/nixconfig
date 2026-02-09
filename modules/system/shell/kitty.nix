{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.kitty;
in
{
  options.modules.system.kitty.enable = lib.mkEnableOption "Terminal Kitty (niveau système)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kitty
    ];
  };
}
